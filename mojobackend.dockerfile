FROM debian:12
USER root
WORKDIR /home/nonroot/mojobuilder
RUN groupadd -r nonroot && useradd -r -g nonroot -d /home/nonroot/mojobuilder -s /bin/bash nonroot
ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1

# setting up python3
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y build-essential software-properties-common curl sudo wget git
RUN apt-get install -y python3 python3-pip python3-venv

# Create and activate venv
RUN python3 -m venv /home/nonroot/mojobuilder/.venv
ENV PATH="/home/nonroot/mojobuilder/.venv/bin:$PATH"

# Install dependencies
RUN pip install -r requirements.txt

RUN UV_HTTP_TIMEOUT=100000 /home/nonroot/.local/bin/pip install -r requirements.txt 

RUN playwright install-deps chromium
RUN playwright install chromium

COPY src /home/nonroot/mojobuilder/src
COPY config.toml /home/nonroot/mojobuilder/
COPY sample.config.toml /home/nonroot/mojobuilder/
COPY mojobuilder.py /home/nonroot/mojobuilder/
RUN chown -R nonroot:nonroot /home/nonroot/mojobuilder

USER nonroot
WORKDIR /home/nonroot/mojobuilder
RUN mkdir /home/nonroot/mojobuilder/db
ENTRYPOINT [ "python3", "-m", "mojobuilder" ]
