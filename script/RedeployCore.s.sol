// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/BuzzSwapFactory.sol";
import "../src/BuzzSwapRouter.sol";
import "../src/bondingCurves/ConstantProductCurve.sol";
import "../src/bondingCurves/ConstantSumCurve.sol";

contract RedeployCore is Script {
    address constant BUZZ = 0x48288D0e3079A03f6EC1846554CFc58C2696Aaee;
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    function run() external {
        vm.startBroadcast();

        // 1. Deploy Constant Product and Constant Sum bonding curves
        address constantProduct = 0x74Ce26A2e4c1368C48A0157CE762944d282896Db;
        address constantSum = 0x7c77704007C9996Ee591C516f7319828BA49d91E;

        // 2. Deploy new BuzzSwapFactory (includes updated pair bytecode)
        BuzzSwapFactory factory = new BuzzSwapFactory(msg.sender);
        console.log("BuzzSwapFactory:", address(factory));

        // 3. Deploy BuzzSwapRouter
        BuzzSwapRouter router = new BuzzSwapRouter(address(factory));
        console.log("BuzzSwapRouter:", address(router));

        // 4. Recreate ETH/BUZZ pair
        address pair1 = factory.createPair(WETH, BUZZ, constantProduct);
        console.log("ETH/BUZZ pair:", pair1);

        // 5. Recreate USDC/BUZZ pair
        address pair2 = factory.createPair(USDC, BUZZ, constantSum);
        console.log("USDC/BUZZ pair:", pair2);

        vm.stopBroadcast();
    }
}