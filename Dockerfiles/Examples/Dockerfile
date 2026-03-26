FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /app
COPY . /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 python3-pip ca-certificates && \
    rm -rf /var/lib/apt/lists/*

CMD ["python3", "app.py"]
