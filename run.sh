#!/bin/bash
DIR=$(dirname "$0")
source "$DIR/solver.conf"
exec "$DIR/cuda-solver" --host "$ENDPOINT" --user "$ACCOUNT" --worker "$NODE_ID"
