# SPEC-1-P2PKH

## Background

Kaspa supports native P2PK (Bech32-encoded single-pubkey) addresses under HRPs `kaspa`, `kaspatest`, etc. We will add a P2PKH-style address type that:

* Computes Blake2b(pubkey)
* Encodes in Bech32 with existing HRPs
* Uses version byte `0x14`

## Prerequisites

* Read/write access to the `rusty-kaspa` repository ([https://github.com/kaspanet/rusty-kaspa](https://github.com/kaspanet/rusty-kaspa))
* Access to the Kaspa Improvement Proposal (KIP) repository for reference: [https://github.com/bitcoinsSG/Kaspa-Post-Quantum-Improvement-Proposal/tree/phase-one](https://github.com/bitcoinsSG/Kaspa-Post-Quantum-Improvement-Proposal/tree/phase-one)
* Local Rust toolchain (stable), including `cargo`, `rustfmt`, and `clippy`
* Familiarity with existing P2PK Bech32 code paths and script engine tests

## Requirements (MoSCoW)

**Must**

* New address version `0x14`
* `fn pubkey_to_blake2b_hash(pubkey: &[u8]) -> [u8; 20]`
* `pub fn execute_p2pkh_script(...)` for script validation
* Reuse Bech32 encode/decode and existing HRPs
* Unit tests: encoding/decoding, script execution, malformed inputs

**Should**

* Concise, self‑documenting names (e.g., `pubkey_to_blake2b_hash`, `execute_p2pkh_script`)
* Clear Rustdoc and comments

**Could**

* Integration tests for sample transactions using the new address type

**Won’t**

* Alter existing P2PK logic or address types
* Add Base58 or checksum layers

---

*Assumptions:* HRPs unchanged; version `0x14` is available.

**Questions:**

1. Include full OP sequence (OP\_DUP, OP\_EQUALVERIFY) or simplify script validation?
2. Any additional formatting or tooling integration requirements?
