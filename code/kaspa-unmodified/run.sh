#!/bin/bash

# Run container in detached mode
docker run -d -p 16110:16110 --name kaspa-unmodified kaspa-unmodified:testnet

# Verify node is running
sleep 5
docker logs kaspa-unmodified | grep "Kaspa node started"
if [ $? -eq 0 ]; then
    echo "Node started successfully. Use 'docker logs kaspa-unmodified' to monitor."
else
    echo "Node failed to start. Check logs: docker logs kaspa-unmodified"
    exit 1
fi