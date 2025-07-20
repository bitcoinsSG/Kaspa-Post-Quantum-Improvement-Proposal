#!/bin/bash

# Remove existing containers
docker stop kaspa-unmodified kaspa-unmodified-debug 2>/dev/null || true
docker rm kaspa-unmodified kaspa-unmodified-debug 2>/dev/null || true

# Build Docker image
docker build -t kaspa-unmodified:testnet . 2>&1 | tee build.log

# Check build success
if [ $? -eq 0 ]; then
    echo "Build successful. Check build.log for details."
else
    echo "Build failed. Check build.log for errors."
    exit 1
fi