#!/bin/bash  

# Create data dir if missing  
mkdir -p ./kaspa-data  
mkdir -p ./kaspa-data/app
mkdir -p ./kaspa-data/app/data

# Build image (if not exists)  
if ! docker image inspect kaspa-testnet &>/dev/null; then  
  docker build -t kaspa-testnet .  
fi  

# Run container  
docker run -it --rm \  
  -v $(pwd)/kaspa-data/app:/app \  
  -p 16110:16110 \  
  kaspa-testnet  
