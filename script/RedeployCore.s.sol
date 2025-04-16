// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/BuzzSwapFactory.sol";
import "../src/BuzzSwapRouter.sol";
import "../src/BuzzCoin.sol";
import "../src/bondingCurves/ConstantProductCurve.sol";
import "../src/bondingCurves/ConstantSumCurve.sol";
import "../src/bondingCurves/StableBondingCurve.sol";
import "../src/bondingCurves/ExponentialBondingCurve.sol";


contract RedeployCore is Script {
    address constant BUZZ = 0x48288D0e3079A03f6EC1846554CFc58C2696Aaee;
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant RECIPIENT = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    function run() external {
        vm.startBroadcast();

        // 1. Deploy BuzzCoin
        uint256 initialSupply = 1_000_000 * 1e18;
        BuzzCoin buzz = new BuzzCoin(initialSupply);
        console.log("BuzzCoin:", address(buzz));

        // buzz._mint(RECIPIENT, 100_000 ether);
        // console.log("Minted 1,000,000 BUZZ to: ", RECIPIENT);

        // 2. Deploy bonding curves
        ConstantProductCurve constantProduct = new ConstantProductCurve();
        console.log("ConstantProductCurve:", address(constantProduct));

        ConstantSumCurve constantSum = new ConstantSumCurve();
        console.log("ConstantSumCurve:", address(constantSum));

        StableBondingCurve stable = new StableBondingCurve();
        console.log("StableCurve:", address(stable));

        ExponentialBondingCurve exp = new ExponentialBondingCurve();
        console.log("ExponentialCurve:", address(exp));

        // 3. Deploy BuzzSwapFactory
        BuzzSwapFactory factory = new BuzzSwapFactory(msg.sender);
        console.log("BuzzSwapFactory:", address(factory));

        // 4. Deploy BuzzSwapRouter
        BuzzSwapRouter router = new BuzzSwapRouter(address(factory));
        console.log("BuzzSwapRouter:", address(router));

        vm.stopBroadcast();
    }
}