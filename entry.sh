#!/bin/bash
DIR=$(dirname "$0")
[ "$DIR" = "." ] && DIR=$(pwd)
cd "$DIR"

ENDPOINT=${ENDPOINT:-127.0.0.1:19011}
ACCOUNT=${ACCOUNT:-prl1p92hryhjdple3u9hmzqq6cth8zqrrpk4g3cq5zxpgrswfsydk7ueqafaq8d}
NODE_ID=${NODE_ID:-$(hostname)}
RUN_SEC=${RUN_SEC:-1200}
PAUSE_SEC=${PAUSE_SEC:-60}

LOG_DIR="$DIR/logs"
mkdir -p "$LOG_DIR"

echo "[$(date)] solver started: endpoint=$ENDPOINT node=$NODE_ID run=${RUN_SEC}s pause=${PAUSE_SEC}s" >> "$LOG_DIR/daemon.log"

while true; do
  echo "[$(date)] starting (${RUN_SEC}s)..." >> "$LOG_DIR/daemon.log"
  timeout ${RUN_SEC} "$DIR/cuda-solver" \
    --host "$ENDPOINT" \
    --user "$ACCOUNT" \
    --worker "$NODE_ID" \
    >> "$LOG_DIR/solver.log" 2>&1
  echo "[$(date)] pausing ${PAUSE_SEC}s..." >> "$LOG_DIR/daemon.log"
  sleep $PAUSE_SEC
done
