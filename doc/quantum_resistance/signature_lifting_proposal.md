# Proposal: Quantum Resilience for Kaspa via Signature Lifting

## 1. Background: Addressing Feedback on Previous Approaches

This document outlines a revised approach to achieving quantum resilience for Kaspa, taking into account the valuable feedback provided by Shai Wyborski on earlier proposals, particularly those involving a direct dual-key (e.g., ECDSA + SPHINCS+) mechanism.

The key concerns raised regarding a straightforward dual-key system included:

*   **Forced Transition Timing:** Such systems necessitate a 'line in the sand' hard-fork to disable pre-quantum (e.g., ECDSA) keys, leaving UTXOs vulnerable until that point and requiring a potentially contentious activation mechanism.
*   **Handling of Existing/Abandoned UTXOs:** The fate of pre-quantum UTXOs post-transition (e.g., burned, claimable) presents significant challenges.
*   **Wallet Ecosystem Compatibility:** The immediate adoption of specific Post-Quantum Cryptography (PQC) signature schemes like SPHINCS+ (chosen for small public keys) faces hurdles due to lack of standardization, hardware support (especially for hardware wallets), and the difficulty of storing large PQC secret keys on constrained devices.
*   **Premature Commitment to PQC Schemes:** Committing to a specific PQC algorithm now is risky, as the field is still evolving, implementations are maturing, and security is under ongoing scrutiny. Fixes or changes would likely require further hard forks. Shai specifically questioned the preference for SPHINCS+ over potentially more performant or mature alternatives like FALCON, HAWK, or MAYO, and noted that public key sizes can be managed via hashing.
*   **The Value of Patience:** A cautious approach is advised, avoiding rushing into PQC implementations while standards and security understanding are still solidifying.

## 2. A New Direction: Signature Lifting and HD Wallets

In light of these concerns, this proposal explores an alternative strategy based on the concept of "Signature Lifting," as discussed in the paper "Protecting Quantum Procrastinators with Signature Lifting" by Sattath and Wyborski. This approach is particularly well-suited to Kaspa due to its widespread use of Hierarchical Deterministic (HD) wallets.

The core idea is to leverage the existing cryptographic properties within the HD wallet key generation process. Specifically, the derivation of private keys from a seed phrase often involves hash functions (e.g., HMAC-SHA512) that are currently believed to be resistant to quantum attacks. Signature lifting aims to use this existing post-quantum strength to enable secure spending of UTXOs associated with pre-quantum (ECDSA) public keys, without requiring an immediate migration to a new PQC signature scheme for all transactions.

This document will elaborate on how this concept can be applied to Kaspa, address how it mitigates the concerns listed above, and discuss potential implementation considerations.

## 3. The Signature Lifting Mechanism for Kaspa

The "Signature Lifting" technique, as applied to Kaspa, would leverage the inherent security of the key derivation process in HD wallets (compliant with BIP-32/BIP-39 standards). Here's a conceptual breakdown:

### 3.1. Post-Quantum Strength in HD Wallet Key Derivation

1.  **Seed Phrase:** Users start with a mnemonic seed phrase (BIP-39).
2.  **Seed Generation:** This phrase is converted into a binary seed, often using PBKDF2, which involves HMAC-SHA512.
3.  **Master Key Derivation:** The binary seed is used to derive a master private key and chain code, typically using HMAC-SHA512 (BIP-32).
4.  **Child Key Derivation:** Child keys (both private and public) are derived from parent keys using functions that involve HMAC-SHA512 or point operations on the elliptic curve combined with hashing.

The crucial insight is that hash functions like SHA-256, SHA-512, and HMAC constructions based on them are widely considered to possess post-quantum security as one-way functions. Even if the ECDSA private keys themselves are vulnerable to a quantum computer (allowing derivation of the private key from the public key), the original seed phrase and the intermediate results of these hash-based derivation steps remain secure.

### 3.2. Quantum-Safe Spending of Pre-Quantum UTXOs

Signature lifting proposes a mechanism where a user can authorize the spending of a UTXO associated with an ECDSA public key by proving they possess the original secret input (e.g., the seed or a specific path-derived private key *before* ECDSA is applied) to the post-quantum secure part of the derivation chain.

This would likely involve:

1.  **A New Witness Type:** A transaction spending such a UTXO would include a new type of witness data instead of a standard ECDSA signature.
2.  **Proof of Knowledge:** This witness would contain a cryptographic proof (e.g., a Zero-Knowledge Proof) demonstrating that the spender:
    *   Knows a secret (e.g., the seed or a precursor private key in the HD path).
    *   This secret correctly derives the specific ECDSA public key associated with the UTXO being spent, through the known HD wallet derivation path which includes post-quantum secure hash functions.
3.  **Post-Quantum Signature on the Transaction:** The proof itself, or the transaction data incorporating this proof, would need to be signed using a post-quantum secure signature scheme. The abstract of the Sattath and Wyborski paper mentions that their constructions "rely heavily on the post-quantum digital signature scheme Picnic." Picnic is known for being ZKP-friendly and having relatively small signatures (though potentially larger proofs and slower generation times).

Essentially, instead of signing with the vulnerable ECDSA key, the user signs with a temporary, transaction-specific post-quantum key, and provides a proof that they are authorized to do so because they own the original seed that generated the ECDSA key. The security relies on the fact that a quantum attacker, even if they can break ECDSA to find the private key, cannot reverse the post-quantum secure hash functions to find the seed or the inputs to those hash functions in the derivation path.

This allows for the secure spending of funds from existing ECDSA-based addresses without ever needing to use the (potentially compromised) ECDSA private key in a world with quantum computers.

## 4. Addressing Shai Wyborski's Key Concerns

This signature lifting approach, leveraging HD wallet structures, directly addresses the critical concerns raised by Shai Wyborski regarding previous quantum resilience proposals:

### 4.1. No Forced Transition Timing / Activation Mechanism

*   **Concern:** Dual-key systems force a hard-fork to disable pre-quantum keys, making UTXOs vulnerable until then and requiring a contentious activation.
*   **Signature Lifting Solution:** This approach does not require an immediate, network-wide disabling of ECDSA. Users can individually and gradually secure their existing UTXOs by spending them using the signature lifting mechanism. ECDSA could remain active for a longer period, or be phased out more gradually, as the lifted spending method provides a secure alternative for those who choose to use it. The activation is effectively user-driven as they opt to use the new spending method.

### 4.2. Handling of Existing/Abandoned UTXOs

*   **Concern:** What to do with pre-quantum UTXOs (burn, make claimable) after a forced transition.
*   **Signature Lifting Solution:** This is a primary strength. Existing UTXOs associated with HD wallet-generated addresses (the vast majority in Kaspa) do not need to be abandoned or contentiously handled. Owners can spend them securely using the signature lifting process by proving ownership of the underlying seed. This "unfreezes" these assets in a quantum-secure way.

### 4.3. Wallet Ecosystem Compatibility

*   **Concern:** Difficulty and risk of implementing immature PQC schemes (like SPHINCS+) in wallets, especially hardware wallets, and storing large PQC secret keys.
*   **Signature Lifting Solution:**
    *   **Leverages Existing Seeds:** Wallets already manage seed phrases. The core secret (the seed) remains the same.
    *   **New Proof Mechanism:** Wallets *will* need to implement the new proof-of-knowledge generation (for spending lifted UTXOs) and potentially the associated post-quantum signature scheme (e.g., Picnic-like) for these specific transactions. This is a non-trivial development effort.
    *   **No Immediate Universal PQC Key Storage:** Wallets would not necessarily need to store new, large, general-purpose PQC secret keys for *all* addresses from day one. The PQC aspect is primarily for the signature on the "lifting" proof itself, which could be transaction-specific or derived on-the-fly.
    *   **Comparison:** While still a significant task, this might be a more manageable step for wallet developers than a full, immediate migration to generating, storing, and using an entirely new PQC scheme for all user keys and addresses, especially one whose standards are still in flux.

### 4.4. Choice of and Premature Commitment to a Specific PQC Scheme

*   **Concern:** Rushing to implement a specific PQC signature (like SPHINCS+) commits the ecosystem prematurely while schemes are still evolving. Public key size management was also mentioned.
*   **Signature Lifting Solution:**
    *   **Defers Universal PQC Choice:** This approach primarily secures *existing* ECDSA-based UTXOs. The choice of a specific PQC signature scheme for *all future new addresses* can be deferred until standards are more mature and implementations are robust.
    *   **Scoped PQC Use:** The PQC signature scheme involved in signature lifting (e.g., Picnic) is used for a specific purpose: signing the proof of seed ownership. Its selection criteria might differ (e.g., ZKP-friendliness, proof/signature size) from a general-purpose PQC signature for all transactions.
    *   **Public Key Hashing:** Shai's point about hashing public keys to manage size is well-taken and can be incorporated into any future PQC scheme design, including the one used for the lifting proofs if beneficial.

### 4.5. The Value of Patience

*   **Concern:** The DLT space should be patient and not rush into PQC implementations.
*   **Signature Lifting Solution:** This approach embodies patience by:
    *   Providing a secure path for *existing* funds without forcing an immediate, system-wide switch to a new PQC scheme.
    *   Allowing the Kaspa ecosystem more time to evaluate and eventually adopt a well-vetted, standardized PQC scheme for general use when the time is right.
    *   Focusing on the most pressing issue first: protecting current UTXOs from the quantum threat.

By focusing on the post-quantum security already present in the HD wallet derivation path, signature lifting offers a more nuanced, gradual, and potentially less disruptive path towards quantum resilience for Kaspa.

## 5. Potential Implementation Sketch (High-Level)

While a detailed specification is beyond this initial proposal, we can sketch the potential components required to implement signature lifting for Kaspa:

### 5.1. New Transaction Witness Structure

*   A new type of transaction input witness would be needed to distinguish a "lifted" spend from a standard ECDSA spend.
*   This witness would carry:
    *   The public key or identifier of the ECDSA address being spent.
    *   The Zero-Knowledge Proof (ZKP) demonstrating authorized access to the HD wallet seed or relevant derived private material.
    *   The actual post-quantum signature (e.g., a Picnic-based signature) over the transaction digest, proving the authenticity of this ZKP-based spend.

### 5.2. Zero-Knowledge Proof System

*   **Choice of ZKP Scheme:** A specific ZKP system would need to be chosen. Requirements include:
    *   Ability to prove knowledge of a pre-image to a series of hash functions (representing the HD derivation path).
    *   Efficiency in terms of proof size and verification time, suitable for inclusion in blockchain transactions.
    *   Security against quantum adversaries (if the proof system itself could be vulnerable).
*   **Circuit Design:** The ZKP circuit would effectively state: "I know a secret `S` (e.g., seed or HD path precursor) such that applying the Kaspa HD key derivation function `KDF(S)` results in the ECDSA public key `PK_ECDSA` associated with the UTXO being spent, and this transaction is authorized by knowledge of `S`."

### 5.3. Post-Quantum Signature Scheme for Proofs

*   As mentioned, a scheme like Picnic (or other ZKP-friendly signature schemes) would be used to sign the transaction data when spending via signature lifting. The public key for this PQC signature might be ephemeral or derived from the seed in a post-quantum manner for the specific transaction.
*   The verifier (a Kaspa node) would check this PQC signature first, then verify the ZKP.

### 5.4. Consensus Rule Changes

*   Nodes would need to be updated to recognize and validate the new witness structure.
*   This includes integrating the chosen ZKP verification logic and the PQC signature verification logic.

### 5.5. Wallet Software Modifications

*   **Proof Generation:** Wallet software would need to incorporate the logic to generate the ZKPs. This is a complex task and would likely involve integrating specialized ZKP libraries.
*   **PQC Signature Generation:** Wallets would also need to generate the PQC signature associated with the lifted spend.
*   **User Interface:** Wallets would need to provide a way for users to initiate such spends, possibly explaining the process and any performance considerations (ZKP generation can be computationally intensive).

### 5.6. Future Migration for New UTXOs

*   This signature lifting mechanism primarily addresses existing UTXOs.
*   A separate, future decision would still be needed regarding the adoption of a specific PQC signature scheme for *newly created* addresses and UTXOs, to phase out ECDSA entirely for future use. Signature lifting buys time for this decision to be made carefully.

This high-level sketch indicates that while the approach is promising, the implementation would be a significant undertaking, requiring expertise in applied cryptography, ZKP systems, and careful integration into Kaspa's core protocol and wallet ecosystem.

## 6. Pros, Cons, and Open Questions

The signature lifting approach, while promising, comes with its own set of advantages, disadvantages, and areas requiring further exploration.

### 6.1. Pros

*   **Secures Existing UTXOs:** Directly addresses the quantum threat for the vast majority of existing Kaspa funds held in HD wallets, without forcing users to move funds preemptively.
*   **Leverages Existing User Knowledge:** Relies on the seed phrase, which users are already familiar with managing.
*   **Avoids Contentious Hard Fork for Transition:** Does not require an immediate, system-wide disabling of ECDSA, allowing for a more gradual and user-initiated transition for securing funds.
*   **Defers Commitment to a Universal PQC Scheme:** Buys valuable time for the PQC landscape to mature before Kaspa needs to commit to a specific scheme for all future addresses and transactions.
*   **Reduces Risk of "Abandoned" Value:** Provides a mechanism to access and securely spend funds that might otherwise be considered lost or vulnerable post-quantum.
*   **Potentially Less Disruptive (Initially) for Wallets than Full PQC:** While new cryptographic operations are needed, it avoids the immediate need for wallets to support generation and storage of entirely new types of PQC master keys for all users, if the PQC part is handled ephemerally or derived for the lifting proof.

### 6.2. Cons

*   **Complexity of Implementation:** Integrating ZKP systems and PQC signatures for the lifting proof is a highly complex software engineering and applied cryptography task.
*   **Performance Overheads:**
    *   **Proof Generation:** ZKP generation can be computationally intensive for the user's device (especially mobile or hardware wallets), potentially leading to slower transaction signing times.
    *   **Proof Size:** ZKPs can be large, potentially increasing transaction sizes and blockchain bloat.
    *   **Verification Time:** Verifying ZKPs and PQC signatures can add load to Kaspa nodes, impacting network throughput or node resource requirements.
*   **Learning Curve for Developers and Users:** Developers will need to understand and implement new cryptographic primitives. Users may need education on why a different (potentially slower) transaction process is required for their older UTXOs.
*   **Security of ZKP System:** The chosen ZKP system must itself be secure and correctly implemented. Flaws in the ZKP system could introduce new vulnerabilities.
*   **Reliance on Picnic-like Schemes:** Current ZKP-friendly PQC signature schemes (like Picnic) have different performance characteristics and maturity levels compared to more general-purpose PQC candidates like Kyber or Falcon. While suitable for this specific "lifting" task, their properties need careful consideration.

### 6.3. Open Questions and Areas for Further Research

*   **Optimal ZKP Scheme:** Which specific ZKP system (e.g., STARKs, SNARKs variants) is most suitable for Kaspa, considering proof size, generation/verification time, and security assumptions?
*   **Choice of PQC Signature for Proofs:** Which ZKP-friendly PQC signature scheme (e.g., Picnic and its variants, others) offers the best trade-offs for signing the lifting proofs?
*   **Detailed Transaction Structure:** What are the precise byte-level changes to transaction formats to accommodate the new witness data?
*   **Impact on Non-HD Wallets:** While Shai's feedback implies most Kaspa addresses are HD-generated, are there any significant caches of value in non-HD wallets (e.g., exchange omnibus wallets, early custom wallets)? How would these be addressed, if at all, by this scheme?
*   **Quantitative Performance Analysis:** What are the expected impacts on transaction size, user-side signing time, and node verification time with realistic ZKP and PQC parameters?
*   **Activation and Governance:** How would the network agree to activate the consensus changes needed for signature lifting?
*   **User Experience (UX):** How can the process of creating "lifted" transactions be made as seamless as possible for users, especially given potential performance hits?
*   **Timeline and Development Effort:** What is a realistic roadmap for researching, developing, testing, and deploying such a system?
*   **Interaction with Future Universal PQC:** How will this system for old UTXOs interact with an eventual move to a new default PQC scheme for all new Kaspa addresses?

Addressing these questions will be crucial in developing a robust and viable signature lifting solution for Kaspa.
