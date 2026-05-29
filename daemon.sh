#!/bin/bash
DIR=$(dirname "$0")
LOG_DIR="$DIR/logs"
mkdir -p "$LOG_DIR"
RUN_SEC=${RUN_SEC:-1200}
PAUSE_SEC=${PAUSE_SEC:-60}
echo "[$(date)] daemon started run=${RUN_SEC}s pause=${PAUSE_SEC}s" >> "$LOG_DIR/daemon.log"
while true; do
  echo "[$(date)] starting solver (${RUN_SEC}s)" >> "$LOG_DIR/daemon.log"
  timeout ${RUN_SEC} "$DIR/run.sh" >> "$LOG_DIR/solver.log" 2>&1
  echo "[$(date)] pausing ${PAUSE_SEC}s" >> "$LOG_DIR/daemon.log"
  sleep $PAUSE_SEC
done
