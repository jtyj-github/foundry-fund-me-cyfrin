// SPDX-License-Identifier: MIT

// 1. Deploy Mocks when we are on local anvil chain
// 2. Keep track of contract address across diff chains
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script{
    // If we are local anvil chain, we deploy mocks
    // Otherwise, grab address from the live network
    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed address
    }

    constructor() {
        if (block.chainid == 11155111){
            activeNetworkConfig = getSepoliaEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    } 

    function getSepoliaEthConfig() public pure returns(NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getOrCreateAnvilEthConfig() public returns(NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)){
            return activeNetworkConfig;
        }
        // 1. Deploy mocks
        // 2. Return mock addresses
        vm.startBroadcast();
        MockV3Aggregator mockPricefeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPricefeed)
        });
        return anvilConfig;
    }
}