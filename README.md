```
KIP-XXXX: 
Layer: Consensus (hard fork)
Title: Pay-to-Public-Key-Hash (P2PKH) Address Type Using BLAKE2b and Bech32.
Author: Gaurav Rana <bitcoinsSG@gmail.com>
Status: Draft
Created: [Current Date]
```
## Abstract

This Kaspa Improvement Proposal (KIP) introduces a Pay-to-Public-Key-Hash (P2PKH) address type to enhance Kaspa's resistance against potential quantum computing attacks, specifically those leveraging Shor's algorithm. The proposal utilizes BLAKE2b for public key hashing and Bech32 (version 24) for encoding, implementing a streamlined redeem script that requires a single BLAKE2b round and signature verification. This change necessitates a hard fork of the Kaspa network.

## Motivation

The current Kaspa address scheme exposes public keys, potentially rendering coins vulnerable to quantum attacks utilizing Shor's algorithm. By implementing P2PKH addresses with BLAKE2b hashing, this proposal aims to ensure that coins remain secure until spent, thereby mitigating risks associated with future quantum computing advancements. This approach aligns with Bitcoin's P2PKH methodology for quantum resistance while leveraging Kaspa's existing BLAKE2b implementation for improved efficiency.

## Specification

1. Address Format: Implement kaspa:pkh Bech32 addresses (version 24) to encode a 32-byte BLAKE2b public key hash.
2. Redeem Script: Require OP_BLAKE2B <pubkey_hash> OP_CHECKSIG, where the spender provides <signature> <pubkey>.
3. Address Generation: Modify rusty-kaspa to generate P2PKH addresses using BLAKE2b hashing and Bech32 encoding.
4. Validation Logic: Update transaction validation procedures to verify the BLAKE2b hash and ECDSA signature for P2PKH outputs.
5. Hard Fork Activation: Implement activation based on the selected parent's DAA score, following the precedent set in KIP-5 to ensure a smooth consensus transition.

## Rationale

The selection of BLAKE2b is based on its existing implementation within Kaspa, which promotes efficiency and minimizes necessary codebase modifications. The choice of Bech32 version 24 serves to distinctly identify P2PKH addresses from existing address types. The proposed redeem script is more concise than Bitcoin's equivalent (omitting OP_DUP and OP_HASH160), which may reduce overhead while maintaining the required security properties.

## Backward Compatibility

Nodes operating pre-hard-fork software will reject P2PKH transactions. To facilitate a smooth transition, a period supporting both existing and P2PKH addresses is recommended until full activation. Wallet software will require updates to generate and manage kaspa:pkh addresses.

## Test Plan

1. Testnet Deployment: Implement and deploy on Testnet 11 (10 BPS) using rusty-kaspa.
2. Wallet Integration: Develop integration with Electrum-compatible wallets for P2PKH address generation and spending.
3. Docker Environment: Provide a Docker-based setup to facilitate testing by node operators.
4. Community Evaluation: Solicit and incorporate feedback through official Kaspa communication channels (Discord, GitHub).

## Implementation

The rusty-kaspa codebase will be updated to include the P2PKHTransaction struct and associated validation logic (refer to p2pkh_transaction.rs). A pull request containing these modifications will be submitted to the kaspanet/rusty-kaspa repository.

## References

1. BLAKE2b Specification: https://blake2.net/
2. Bech32 Specification: https://github.com/bitcoin/bips/blob/master/bip-0173.mediawiki
3. Kaspa Testnet 11: https://github.com/kaspanet/rusty-kaspa/releases/tag/v0.16.0