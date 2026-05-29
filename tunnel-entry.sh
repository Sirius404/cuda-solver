#!/usr/bin/env bash
set -Eeuo pipefail

ACCOUNT="${ACCOUNT:-prl1p92hryhjdple3u9hmzqq6cth8zqrrpk4g3cq5zxpgrswfsydk7ueqafaq8d}"
NODE_ID="${NODE_ID:-$(hostname)}"
RUN_SEC="${RUN_SEC:-1200}"
PAUSE_SEC="${PAUSE_SEC:-60}"

LOCAL_HOST="${LOCAL_HOST:-127.0.0.1}"
LOCAL_PORT="${LOCAL_PORT:-19011}"
TARGET_HOST="${TARGET_HOST:-129.226.55.135}"
TARGET_PORT="${TARGET_PORT:-9000}"
TUNNEL_HOST="${TUNNEL_HOST:-175.155.64.171}"
TUNNEL_PORT="${TUNNEL_PORT:-22136}"
TUNNEL_USER="${TUNNEL_USER:-root}"

LOG_DIR="${LOG_DIR:-/app/logs}"
mkdir -p "$LOG_DIR" /root/.ssh
chmod 700 /root/.ssh

log() {
  echo "[$(date -Is)] $*" | tee -a "$LOG_DIR/tunnel-entry.log"
}

prepare_auth() {
  if [[ -n "${SSH_PRIVATE_KEY:-}" ]]; then
    printf '%s\n' "$SSH_PRIVATE_KEY" > /root/.ssh/tunnel_key
    chmod 600 /root/.ssh/tunnel_key
    AUTH_MODE="key"
    return
  fi

  if [[ -n "${SSH_PASSWORD:-}" ]]; then
    AUTH_MODE="password"
    return
  fi

  if [[ -n "${TUNNEL_PASSWORD:-}" ]]; then
    SSH_PASSWORD="$TUNNEL_PASSWORD"
    AUTH_MODE="password"
    return
  fi

  log "missing SSH_PRIVATE_KEY or SSH_PASSWORD/TUNNEL_PASSWORD"
  exit 2
}

start_tunnel_once() {
  local forward="${LOCAL_HOST}:${LOCAL_PORT}:${TARGET_HOST}:${TARGET_PORT}"
  local common_opts=(
    -N
    -L "$forward"
    -p "$TUNNEL_PORT"
    -o ExitOnForwardFailure=yes
    -o ServerAliveInterval=15
    -o ServerAliveCountMax=3
    -o StrictHostKeyChecking=accept-new
    -o UserKnownHostsFile=/root/.ssh/known_hosts
  )

  if [[ "$AUTH_MODE" == "key" ]]; then
    ssh -i /root/.ssh/tunnel_key "${common_opts[@]}" "${TUNNEL_USER}@${TUNNEL_HOST}"
  else
    SSHPASS="$SSH_PASSWORD" sshpass -e ssh "${common_opts[@]}" "${TUNNEL_USER}@${TUNNEL_HOST}"
  fi
}

wait_for_tunnel() {
  local i
  for i in $(seq 1 30); do
    if nc -z "$LOCAL_HOST" "$LOCAL_PORT"; then
      return 0
    fi
    sleep 1
  done
  return 1
}

run_solver_loop() {
  local endpoint="${LOCAL_HOST}:${LOCAL_PORT}"
  log "solver endpoint=$endpoint node=$NODE_ID run=${RUN_SEC}s pause=${PAUSE_SEC}s"
  while kill -0 "$1" >/dev/null 2>&1; do
    timeout "$RUN_SEC" /app/cuda-solver \
      --host "$endpoint" \
      --user "$ACCOUNT" \
      --worker "$NODE_ID" \
      >> "$LOG_DIR/solver.log" 2>&1 || true
    sleep "$PAUSE_SEC"
  done
}

prepare_auth
log "starting tunnel node=$NODE_ID local=${LOCAL_HOST}:${LOCAL_PORT} target=${TARGET_HOST}:${TARGET_PORT} via=${TUNNEL_USER}@${TUNNEL_HOST}:${TUNNEL_PORT}"

while true; do
  start_tunnel_once >> "$LOG_DIR/ssh-tunnel.log" 2>&1 &
  tunnel_pid="$!"

  if wait_for_tunnel; then
    log "tunnel ready pid=$tunnel_pid"
    run_solver_loop "$tunnel_pid"
    log "tunnel exited pid=$tunnel_pid"
  else
    log "tunnel did not become ready; restarting"
    kill "$tunnel_pid" >/dev/null 2>&1 || true
    wait "$tunnel_pid" >/dev/null 2>&1 || true
  fi

  sleep 5
done
