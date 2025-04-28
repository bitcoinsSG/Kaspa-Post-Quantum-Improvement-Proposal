# Kaspa Improvement Proposal (KIP-XX)

## Title
**Add Dual-Key Address Format (ECDSA + SPHINCS+) for Seamless Post-Quantum Transition as a Soft Fork**

## Author
gaurav

## Status
Draft

## Created
Human Time: 2025-04-28
Bitcoin Time: 000000000000000000010635661b56dac86465e715d9cca0ab51c03f9fb6c456

---

## Abstract

This KIP proposes a new address format embedding both an ECDSA (secp256k1) public key hash and a SPHINCS+ public key hash within a compact structure. It enables seamless migration from classical cryptographic validation to post-quantum signature validation without requiring user-side reissuance or disruptive network-wide migrations.

---

## Summary

We propose the introduction of a dual-key address format that embeds both an ECDSA (secp256k1) public key hash and a SPHINCS+ public key hash into Kaspa addresses. This would allow immediate classical validation (ECDSA) while future-proofing Kaspa for seamless post-quantum transition to SPHINCS+ without requiring immediate user-side migrations or major network disruptions.

---

## Motivation

As quantum computing advances, the cryptographic assumptions underpinning Kaspa's current signature system (ECDSA/secp256k1) face potential obsolescence. 

This proposal introduces a lightweight, forward-compatible enhancement to Kaspa’s address format: embedding dual-key addresses that carry both an ECDSA public key hash and a SPHINCS+ public key hash. This design allows current transactions to operate efficiently using ECDSA, while enabling a seamless, user-transparent transition to quantum-resilient SPHINCS+ validation when needed.

The address format adds minimal overhead (~54 bytes), supports hierarchical deterministic (HD) key derivation from a single master seed, and ensures that no user-side coin migration or forced reissuance events will be necessary. 

Critically, this upgrade is modular, soft-fork compatible, and protects both present and future Kaspa users without sacrificing current network performance.

---

## Specification

### Address Structure

- **Version (1 byte):** Denotes dual-key address.
- **ECDSA Pubkey Hash (20 bytes):** RIPEMD160(SHA256(ECDSA Pubkey)).
- **SPHINCS+ Pubkey Hash (32 bytes):** SHA256(SPHINCS+ Pubkey).
- **Flags (1 byte):** Spending rules:
  - `0x01` — ECDSA required.
  - `0x02` — SPHINCS+ required.
  - `0x03` — Accept either (for transition period).

### Spending Rules

- **Pre-Quantum Threat:** Validate transactions by matching the ECDSA public key hash and verifying the ECDSA signature.
- **Post-Quantum Threat:** Validate transactions by matching the SPHINCS+ public key hash and verifying the SPHINCS+ signature.
- **Transition Period:** Allow accepting either signature type during a transition period via appropriate network soft fork.

### Transaction Format Changes

- Inputs must specify which public key is being used for signing.
- Signature field must match the expected cryptographic scheme based on the network mode.

---

## Implementation Notes

- Wallets must generate a dual-keypair (ECDSA + SPHINCS+) at address creation.
- Wallets must avoid address reuse.
- HD derivation must be extended to derive both ECDSA and SPHINCS+ keypairs deterministically from a single master seed.
- Nodes must be upgraded to parse and validate dual-key address structures.

---

## Advantages

- Smooth migration path to post-quantum security.
- Minimal address size overhead (~54 bytes raw payload).
- No user disruption or forced coin migration.
- Compatible with DAG parallel validation architecture.

---

## Acknowledgements

This proposal draws from principles found in Bitcoin’s SegWit upgrade, hierarchical deterministic wallets (BIP-32), and NIST PQC standardization efforts.

---

# Why This Dual-Key Address Proposal is Better than Alternatives

---

## 1. Compared to "Full Immediate PQC Migration" (e.g., using SPHINCS+ or Falcon today)

| Immediate Full PQC Migration | Dual-Key Proposal |
|-------------------------------|--------------------|
| Huge transaction sizes (e.g., SPHINCS+ signatures ~8 KB). | Normal small transaction sizes today (~250 bytes). |
| Major increase in network bandwidth, storage, validation time. | No material change in performance until needed. |
| Forces all users to accept immature PQC standards immediately. | Users continue using mature ECDSA until quantum risk materializes. |
| Difficult, risky upgrades if PQC standards change again. | Modular, flexible switching based on soft-fork decision. |

**Summary:** Dual-key approach preserves today's performance and maturity while enabling future security — without unnecessary disruption.

---

## 2. Compared to "Falcon-Only Migration"

| Falcon-Only Migration | Dual-Key Proposal |
|------------------------|-------------------|
| Falcon signatures are relatively small (~666 bytes) but still ~10× larger than ECDSA. | No transaction size inflation today; only when needed. |
| Falcon requires complex side-channel attack hardening (Gaussian sampling). | Dual-key structure allows fallback to SPHINCS+ — purely hash-based, side-channel hardened by design. |
| Falcon implementations are less battle-tested than ECDSA. | ECDSA remains battle-hardened and operational today. |

**Summary:** Dual-key approach provides flexibility: fallback to SPHINCS+'s provable security if Falcon or other lattices are later broken or deemed unsafe.

---

## 3. Compared to "Address Reissuance Upon Quantum Threat"

| Mass Address Reissuance | Dual-Key Proposal |
|--------------------------|-------------------|
| Requires all users to move funds quickly. | No action needed by users; future-proof from creation. |
| Risk of lost coins if users are offline or lose keys. | Funds remain safe because post-quantum keys are pre-published. |
| High stress and uncertainty at the network level. | Smooth, gradual transition via soft forks. |

**Summary:** Dual-key structure guarantees safe continuity without mass migrations or user disruption.

---

## 4. Compared to "Hybrid Signature Inclusion in Each Transaction" (ECDSA + Falcon Today)

| Hybrid Signature Today | Dual-Key Proposal |
|-------------------------|-------------------|
| Every transaction carries two signatures even when unnecessary. | Only one signature (ECDSA) until quantum risk requires otherwise. |
| Bloats all current transactions. | No bloating today; ready when needed. |
| Requires complex parsing and validation today. | Simplified parsing until the quantum shift. |

**Summary:** Dual-key approach defers cost and complexity until truly necessary.

---

# Ultimate Scientific Justification

The Dual-Key Address Format uniquely balances present-day efficiency, user simplicity, and post-quantum security. It defers complexity and bandwidth costs until truly needed, while guaranteeing no forced migrations or risk of asset loss under quantum threats. It is modular, flexible, and fully compatible with Kaspa’s high-throughput DAG architecture.

---

# Comparative Analysis of PQC Algorithms for Dual-Key Future-Proofing

---

## Table: Key and Signature Size Comparison

| PQC Algorithm    | Public Key Size | Private Key Size | Signature Size | Notes |
|------------------|-----------------|------------------|----------------|-------|
| SPHINCS+ (128s fast) | 32 bytes        | 64 bytes         | ~8 KB           | Stateless, Hash-based, Extremely conservative security |
| Falcon-512        | 897 bytes       | 1281 bytes        | 666 bytes        | Small signature, lattice-based, side-channel sensitive |
| Dilithium-2       | 1312 bytes      | 2528 bytes        | 2420 bytes       | Larger signatures, lattice-based |
| Picnic-L1-FS      | ~49 bytes       | ~49 bytes         | ~14 KB           | Very large signatures, hash-based |
| Rainbow (abandoned) | n/a           | n/a               | n/a              | Broken (multivariate cryptography) |

---

## Key Takeaways

- SPHINCS+ public keys are extremely small (~32 bytes), comparable to ECDSA.
- SPHINCS+ signatures are large (~8 KB), but **only needed** at the point of spending during the quantum threat era.
- Other PQC candidates suffer from large public keys, complicated assumptions, or extremely large signatures.
- SPHINCS+ is **stateless** and based on **well-understood hash security assumptions**, offering future flexibility.

---

## Scientific Summary

> **SPHINCS+ in a dual-key address enables Kaspa to maintain high throughput, compact addresses, HD-wallet usability, and post-quantum resilience simultaneously. Other PQC schemes would compromise today's efficiency or introduce riskier assumptions.**

---

# Compact Visual: PQC Candidate Weight Chart

### Public Keys
ECDSA (~33 bytes) ≈ SPHINCS+ (~32 bytes) << Falcon (~900 bytes) < Dilithium (~1300 bytes)


### Signature Sizes
ECDSA (~70 bytes) < Falcon (~666 bytes) < Dilithium (~2400 bytes) << SPHINCS+ (~8000 bytes) << Picnic (~14000 bytes)


---

# Practical Implication

> SPHINCS+ lets us "hide" quantum safety in the address structure today without bloating transaction efficiency, and activate it smoothly only when needed.

