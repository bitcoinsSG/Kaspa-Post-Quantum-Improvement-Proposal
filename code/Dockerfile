# Base: Ubuntu 22.04 (minimal + wget)
FROM ubuntu:22.04

# Install deps - proper line continuation
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    libssl-dev \
    wget \
    unzip && \
    rm -rf /var/lib/apt/lists/*

# Set working directory early
WORKDIR /app

# Download binary
ARG KASPA_VERSION="1.0.0"
RUN wget -q "https://github.com/kaspanet/rusty-kaspa/releases/download/v${KASPA_VERSION}/rusty-kaspa-v${KASPA_VERSION}-linux-amd64.zip" && \
    unzip rusty-kaspa-*.zip && \
    rm rusty-kaspa-*.zip

# Run as non-root
RUN useradd -m kaspa && \
    mkdir -p /app/data && \
    chown -R kaspa:kaspa /app
USER kaspa

# Default command
CMD ["./kaspa", "--testnet", "--data-dir", "/app/data"]
