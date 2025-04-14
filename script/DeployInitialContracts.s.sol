// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/BuzzSwapFactory.sol";
import "../src/BuzzCoin.sol";
import "../src/bondingCurves/ConstantProductCurve.sol";
import "../src/bondingCurves/ConstantSumCurve.sol";

contract DeployInitialContracts is Script {
    function run() external {
        vm.startBroadcast();

        uint256 initialSupply = 1_000_000 * 1e18;
        BuzzCoin buzz = new BuzzCoin(initialSupply);
        ConstantProductCurve constantProduct = new ConstantProductCurve();
        ConstantSumCurve constantSum = new ConstantSumCurve();
        BuzzSwapFactory factory = new BuzzSwapFactory(msg.sender);

        console.log("BuzzCoin: ", address(buzz));
        console.log("ConstantProductCurve: ", address(constantProduct));
        console.log("ConstantSumCurve: ", address(constantSum));
        console.log("BuzzSwapFactory: ", address(factory));

        vm.stopBroadcast();
    }
}