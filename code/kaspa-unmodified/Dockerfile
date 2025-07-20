FROM debian:bookworm-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    apt-utils \
    build-essential \
    curl \
    git \
    libssl-dev \
    pkg-config \
    protobuf-compiler \
    libprotobuf-dev \
    clang \
    clang-format \
    clang-tidy \
    clang-tools \
    clangd \
    libc++-dev \
    libc++1 \
    libc++abi-dev \
    libc++abi1 \
    libclang-dev \
    libclang1 \
    liblldb-dev \
    libllvm-ocaml-dev \
    libomp-dev \
    libomp5 \
    lld \
    lldb \
    llvm-dev \
    llvm-runtime \
    llvm \
    python3-clang \
    libsnappy-dev \
    zlib1g-dev \
    libbz2-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Update Rust and install wasm32 target
RUN rustup update && rustup target add wasm32-unknown-unknown

# Install wasm-pack
RUN cargo install wasm-pack

# Clone rusty-kaspa
WORKDIR /app
RUN git clone https://github.com/kaspanet/rusty-kaspa.git
WORKDIR /app/rusty-kaspa

# Build without modifications
RUN cargo build --release

# Expose Testnet port
EXPOSE 16110

# Run kaspad on Testnet
CMD ["cargo", "run", "--release", "--bin", "kaspad", "--", "--testnet"]