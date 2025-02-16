FROM debian:12
USER root
WORKDIR /home/nonroot/devika
RUN groupadd -r nonroot && useradd -r -g nonroot -d /home/nonroot/devika -s /bin/bash nonroot
ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1

# setting up python3
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y build-essential software-properties-common curl sudo wget git
RUN apt-get install -y python3 python3-pip python3-venv

# Create and activate venv
RUN python3 -m venv /home/nonroot/devika/.venv
ENV PATH="/home/nonroot/devika/.venv/bin:$PATH"

# Install dependencies
COPY requirements.txt /home/nonroot/devika/
RUN UV_HTTP_TIMEOUT=100000 /home/nonroot/.local/bin/uv pip install -r requirements.txt 

RUN playwright install-deps chromium
RUN playwright install chromium

COPY src /home/nonroot/devika/src
COPY config.toml /home/nonroot/devika/
COPY sample.config.toml /home/nonroot/devika/
COPY devika.py /home/nonroot/devika/
RUN chown -R nonroot:nonroot /home/nonroot/devika

USER nonroot
WORKDIR /home/nonroot/devika
RUN mkdir /home/nonroot/devika/db
ENTRYPOINT [ "python3", "-m", "devika" ]
