use starknet::ContractAddress;
use snforge_std::{declare, ContractClassTrait, DeclareResultTrait};
use rwax::interfaces::irwa_factory::{IRWAFactoryDispatcher, IRWAFactoryDispatcherTrait};
use core::serde::Serde;

/// Test helper function to deploy the RWAFactory contract
fn deploy_rwa_factory() -> IRWAFactoryDispatcher {
    let contract = declare("RWAFactory").unwrap().contract_class();

    // Constructor parameters
    let name: ByteArray = "RWA Token";
    let symbol: ByteArray = "RWA";
    let base_uri: ByteArray = "https://api.rwax.com/metadata/";
    let admin: ContractAddress = 0x123.try_into().unwrap();
    let fractionalization_module: ContractAddress = 0x456.try_into().unwrap();

    let mut constructor_calldata = array![];
    name.serialize(ref constructor_calldata);
    symbol.serialize(ref constructor_calldata);
    base_uri.serialize(ref constructor_calldata);
    admin.serialize(ref constructor_calldata);
    fractionalization_module.serialize(ref constructor_calldata);

    let (contract_address, _) = contract.deploy(@constructor_calldata).unwrap();
    IRWAFactoryDispatcher { contract_address }
}

#[test]
fn test_get_total_assets_initial_state() {
    // Test that get_total_assets returns 0 when no assets have been tokenized
    // This is the core functionality we're implementing for issue #79
    let rwa_factory = deploy_rwa_factory();
    
    let total_assets = rwa_factory.get_total_assets();
    
    assert_eq!(total_assets, 0_u256, "Initial total assets should be 0");
}

#[test]
fn test_get_total_assets_view_function_properties() {
    // Test that get_total_assets is a view function and doesn't modify state
    // This verifies the function signature and basic behavior
    let rwa_factory = deploy_rwa_factory();
    
    // Call get_total_assets multiple times and verify it doesn't change
    let initial_count = rwa_factory.get_total_assets();
    let second_count = rwa_factory.get_total_assets();
    let third_count = rwa_factory.get_total_assets();
    
    assert_eq!(initial_count, 0_u256, "Initial count should be 0");
    assert_eq!(second_count, 0_u256, "Second call should return same value");
    assert_eq!(third_count, 0_u256, "Third call should return same value");
    assert_eq!(initial_count, second_count, "Multiple calls should return consistent results");
    assert_eq!(second_count, third_count, "Multiple calls should return consistent results");
}

#[test]
fn test_get_total_assets_function_signature() {
    // Test that the function has the correct signature as specified in the interface
    // This ensures we've implemented the function correctly according to the requirements
    let rwa_factory = deploy_rwa_factory();

    // The function should take a snapshot of ContractState and return u256
    let result: u256 = rwa_factory.get_total_assets();

    // Verify the return type is u256 and the initial value is 0
    assert_eq!(result, 0_u256, "Function should return u256 type with initial value 0");
}

#[test]
fn test_get_total_assets_incremental_behavior() {
    // Test that get_total_assets correctly increments when assets are tokenized
    // This validates the core functionality described in issue #79
    let rwa_factory = deploy_rwa_factory();
    let owner: ContractAddress = 0x789.try_into().unwrap();

    // Verify initial state
    assert_eq!(rwa_factory.get_total_assets(), 0_u256, "Should start with 0 assets");

    // Tokenize first asset
    let asset_data_1: felt252 = 'asset_1';
    let token_id_1 = rwa_factory.tokenize_asset(owner, asset_data_1);
    assert_eq!(rwa_factory.get_total_assets(), 1_u256, "Should have 1 asset after first tokenization");
    assert_eq!(token_id_1, 1_u256, "First token ID should be 1");

    // Tokenize second asset
    let asset_data_2: felt252 = 'asset_2';
    let token_id_2 = rwa_factory.tokenize_asset(owner, asset_data_2);
    assert_eq!(rwa_factory.get_total_assets(), 2_u256, "Should have 2 assets after second tokenization");
    assert_eq!(token_id_2, 2_u256, "Second token ID should be 2");

    // Tokenize third asset
    let asset_data_3: felt252 = 'asset_3';
    let token_id_3 = rwa_factory.tokenize_asset(owner, asset_data_3);
    assert_eq!(rwa_factory.get_total_assets(), 3_u256, "Should have 3 assets after third tokenization");
    assert_eq!(token_id_3, 3_u256, "Third token ID should be 3");
}
