# KIP: Post-Quantum Signature Scheme for Kaspa  
**Author:** gaurav (@bitcoinssg)  
**Created:** 2024-03-15  (000000000000000000010635661b56dac86465e715d9cca0ab51c03f9fb6c456)
**Status:** Draft  
**Type:** Standards Track  
**Category:** Core  

## Abstract  
This proposal upgrades Kaspa's signature scheme to SPHINCS+, a quantum-resistant algorithm, ensuring long-term security against quantum computing threats while maintaining compatibility with Kaspa's high-throughput architecture.

## Motivation  
Quantum computers will eventually break ECDSA signatures used in Kaspa today. As a blockchain designed for longevity, Kaspa must adopt post-quantum cryptography before quantum computers become viable. SPHINCS+ provides the most conservative security guarantees among NIST-standardized options.

## Comparative Analysis  
### Signature Schemes Evaluated  

| Scheme    | Type       | PQ Secure | Sig Size | Key Sizes  | Performance |  
|-----------|------------|-----------|----------|------------|-------------|  
| ECDSA     | Elliptic Curve | ❌ No  | 64-72B  | 32B/32B   | ⚡ Fastest |  
| SPHINCS+  | Hash-Based | ✅ Yes | 49,856B | 64B/128B  | 🐢 Slowest |  
| Dilithium | Lattice    | ✅ Yes | 2,368B  | 1.3KB/2.5KB | � Moderate |  
| Falcon    | Lattice    | ✅ Yes | 690-1,330B | 0.9-1.3KB | ⚡ Fast |  

### Selection Rationale  
SPHINCS+ was chosen because:  
1. No patents (unlike Falcon)  
2. Simpler security assumptions (only hash functions)  
3. Standardized by NIST (PQC Round 3 Finalist)  

## Specification  
### Transaction Format (Version 2)  
New transaction structure will use:  
- `version: 2` (current is 1)  
- `sig_type: 0x1 (ECDSA) or 0x2 (SPHINCS+)`  
- `signature`: Variable-length field (72B for ECDSA, 49,856B for SPHINCS+)  

Example SPHINCS+ transaction hex:  
`02000000...0100000000...028945a3...<49KB sig>...00000000`

### Network Upgrade  
1. Activation Height: Block 1,500,000 (mainnet)  
2. Signaling: Miner bit 4 in block headers  
3. Grace Period: 10,240 blocks (~14 days)  

## Reference Implementation  
1. kaspad Modifications: New transaction validation logic  
2. Wallet Requirements: Key generation updates  

## Backward Compatibility  
### Transition Timeline  
| Phase | Blocks      | ECDSA | SPHINCS+ |  
|-------|-------------|-------|----------|  
| 1     | Pre-1.5M    | ✅    | ❌       |  
| 2     | 1.5M-1.6M   | ✅    | ✅       |  
| 3     | Post-1.6M   | ❌    | ✅       |  

## Performance Metrics  
| Operation | ECDSA | SPHINCS+ | Overhead |  
|-----------|-------|----------|----------|  
| Sign      | 0.5ms | 50ms     | 100x     |  
| Verify    | 1ms   | 10ms     | 10x      |  

## References  
1. [NIST SPHINCS+ Specification](https://sphincs.org/)  
2. [KIP-0002: Transaction Format](https://github.com/kaspanet/kips/blob/master/kip-0002.md)  
