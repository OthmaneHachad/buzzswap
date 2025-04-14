// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/BuzzSwapFactory.sol";

contract DeployPairs is Script {
    // === Deployed Token Addresses (use actual ones from your setup)
    address constant BUZZ = 0x48288D0e3079A03f6EC1846554CFc58C2696Aaee;  // Your BuzzCoin
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; // Mainnet USDC
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // Native ETH placeholder

    // === Bonding Curve Addresses (must be deployed already)
    address constant CURVE_CONSTANT_PRODUCT = 0x74Ce26A2e4c1368C48A0157CE762944d282896Db;
    address constant CURVE_CONSTANT_SUM = 0x7c77704007C9996Ee591C516f7319828BA49d91E;
    // **** SET LATER WHEN FIXED *******
    // address constant CURVE_STABLE = 0x...;

    // === Deployed Factory
    address constant FACTORY = 0x676F5F71DAE1C83Dc31775E4c61212bC9e799d9C;  // Your BuzzSwapFactory address

    function run() external {
        vm.startBroadcast();

        BuzzSwapFactory factory = BuzzSwapFactory(FACTORY);

        // === ETH/BUZZ using Constant Product
        {
            (address token0, address token1) = WETH < BUZZ ? (WETH, BUZZ) : (BUZZ, WETH);

            if (factory.getPair(token0, token1) == address(0)) {
                address pair = factory.createPair(WETH, BUZZ, CURVE_CONSTANT_PRODUCT);
                console.log("ETH/BUZZ pair deployed at:", pair);
            } else {
                console.log("ETH/BUZZ pair already exists");
            }
        }

        // === USDC/BUZZ using Constant Sum
        {
            (address token0, address token1) = USDC < BUZZ ? (USDC, BUZZ) : (BUZZ, USDC);

            if (factory.getPair(token0, token1) == address(0)) {
                address pair = factory.createPair(USDC, BUZZ, CURVE_CONSTANT_SUM);
                console.log("USDC/BUZZ pair deployed at:", pair);
            } else {
                console.log("USDC/BUZZ pair already exists");
            }
        }

        // === ETH/USDC with Stable Curve (TO ENABLE LATER)
        /*
        {
            (address token0, address token1) = WETH < USDC ? (WETH, USDC) : (USDC, WETH);

            if (factory.getPair(token0, token1) == address(0)) {
                address pair = factory.createPair(WETH, USDC, CURVE_STABLE);
                console.log("ETH/USDC pair deployed at:", pair);
            } else {
                console.log("ETH/USDC pair already exists");
            }
        }
        */

        vm.stopBroadcast();
    }
}