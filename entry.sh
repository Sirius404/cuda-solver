#!/bin/bash
NODE_ID=${NODE_ID:-$(hostname)}
if [ "${DAEMON_MODE:-1}" = "1" ]; then
  exec ./daemon.sh
else
  exec ./cuda-solver --host "$ENDPOINT" --user "$ACCOUNT" --worker "$NODE_ID"
fi
