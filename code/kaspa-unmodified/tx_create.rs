use kaspa_core::transaction::{Transaction, TransactionInput, TransactionOutput, ScriptPublicKey};
use kaspa_core::sign::sign_message;
use kaspa_hashes::Hash;
use kaspa_addresses::{Address, Prefix};
use kaspa_consensus::model::stores::utxo::UtxoEntry;
use kaspa_rpc_client::RpcClient;
use hex;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let privkey = hex::decode("your_private_key_here")?;
    let pubkey = hex::decode("your_public_key_here")?;
    let sender_address = Address::new(Prefix::Testnet, 0, &pubkey)?;
    println!("Sender Address: {}", sender_address);

    let recipient_address = Address::from_str("kaspa:recipient_address_here")?;
    let recipient_pubkey = recipient_address.payload().to_vec();

    let utxo = TransactionInput {
        previous_outpoint: Outpoint {
            tx_id: Hash::from_bytes(hex::decode("your_faucet_txid_here")?.try_into().map_err(|_| "Invalid txid length")?),
            index: 0,
        },
        signature_script: vec![],
        sequence: 0,
        sig_op_count: 1,
    };

    let output = TransactionOutput {
        value: 1000,
        script_public_key: ScriptPublicKey::new(0, recipient_pubkey),
    };

    let mut tx = Transaction::new(0, vec![utxo], vec![output], 0, 0, 0);
    let tx_hash = tx.compute_hash();
    let signature = sign_message(&privkey, tx_hash.as_bytes())?;
    tx.inputs[0].signature_script = signature;

    let utxo_set = UtxoSet::new(vec![(utxo.previous_outpoint, UtxoEntry {
        amount: 2000,
        script_public_key: ScriptPublicKey::new(0, pubkey),
        block_daa_score: 0,
        is_coinbase: false,
    })]);
    assert!(tx.is_valid(&utxo_set)?, "Transaction validation failed");

    let client = RpcClient::new("localhost:16110")?;
    client.submit_transaction(&tx)?;
    println!("Transaction submitted: {}", tx.id());

    Ok(())
}