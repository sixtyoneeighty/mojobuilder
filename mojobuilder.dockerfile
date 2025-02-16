# Use Debian 12 as the base image
FROM debian:12

# Set up build variable
ARG VITE_API_BASE_URL
ENV VITE_API_BASE_URL=${VITE_API_BASE_URL}

# Set up OS environment
USER root
WORKDIR /home/nonroot/client
RUN groupadd -r nonroot && useradd -r -g nonroot -d /home/nonroot/client -s /bin/bash nonroot

# Update system and install dependencies
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y build-essential software-properties-common curl sudo wget git

# Install Node.js properly (without npm conflict)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g npm

# Install Bun
RUN curl -fsSL https://bun.sh/install | bash && \
    echo 'export BUN_INSTALL="$HOME/.bun"' >> ~/.bashrc && \
    echo 'export PATH="$BUN_INSTALL/bin:$PATH"' >> ~/.bashrc

# Set environment variables for Bun (in case they are needed in the build process)
ENV BUN_INSTALL="/root/.bun"
ENV PATH="${BUN_INSTALL}/bin:${PATH}"

# Copy Mojo app client files
COPY ui /home/nonroot/client/ui
COPY src /home/nonroot/client/src
COPY config.toml /home/nonroot/client/

# Install dependencies
WORKDIR /home/nonroot/client/ui
RUN npm install && npm install -g bun

# Set permissions
RUN chown -R nonroot:nonroot /home/nonroot/client

# Switch to nonroot user
USER nonroot
WORKDIR /home/nonroot/client/ui

# Run the application on port 1337 and expose it to the outside world
ENTRYPOINT [ "bun", "run", "dev", "--", "--host", "0.0.0.0", "--port", "1337" ]