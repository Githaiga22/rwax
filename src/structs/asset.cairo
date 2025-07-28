use starknet::ContractAddress;

/// Represents the metadata and information for a real-world asset (RWA)
/// This struct contains all the essential data needed to tokenize and track
/// real-world assets on the blockchain
#[derive(Drop, Serde, starknet::Store)]
pub struct AssetData {
    /// Type of the asset (e.g., "real_estate", "art", "commodity")
    pub asset_type: felt252,
    /// Unique identifier for the asset (could be a hash of asset details)
    pub asset_id: felt252,
    /// Current valuation of the asset in wei (base currency units)
    pub valuation: u256,
    /// IPFS hash or URI pointing to detailed asset documentation
    pub metadata_uri: felt252,
    /// Timestamp when the asset was last appraised or valued
    pub last_appraisal_date: u64,
    /// Address of the original asset owner/tokenizer
    pub original_owner: ContractAddress,
    /// Whether the asset is currently active/valid for trading
    pub is_active: bool,
}
