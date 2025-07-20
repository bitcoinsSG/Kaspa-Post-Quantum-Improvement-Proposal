#!/bin/bash

# Run in container
docker exec -it kaspa-unmodified bash -c "
    cd /app/rusty-kaspa

    # Generate sender keypair
    echo 'Generating sender address...'
    SENDER_OUTPUT=\$(cargo run --release --bin kaspa-cli -- generate-address)
    SENDER_ADDRESS=\$(echo \"\$SENDER_OUTPUT\" | grep 'Address' | cut -d' ' -f2)
    SENDER_PRIVATE_KEY=\$(echo \"\$SENDER_OUTPUT\" | grep 'Private Key' | cut -d' ' -f3)
    echo \"Sender Address: \$SENDER_ADDRESS\"
    echo \"Sender Private Key: \$SENDER_PRIVATE_KEY\"

    # Generate recipient address
    echo 'Generating recipient address...'
    RECIPIENT_ADDRESS=\$(cargo run --release --bin kaspa-cli -- generate-address | grep 'Address' | cut -d' ' -f2)
    echo \"Recipient Address: \$RECIPIENT_ADDRESS\"

    # Prompt for UTXO data
    echo 'Please provide the Testnet faucet transaction ID (hex):'
    read TXID
    echo 'Please provide the UTXO index (e.g., 0):'
    read INDEX
    echo 'Please provide the UTXO amount (in sompi, e.g., 2000):'
    read AMOUNT

    # Create and submit transaction
    echo 'Creating and submitting transaction...'
    cargo run --release --bin kaspa-cli -- send --address \$RECIPIENT_ADDRESS --amount \$AMOUNT --utxo \$TXID:\$INDEX --private-key \$SENDER_PRIVATE_KEY
"