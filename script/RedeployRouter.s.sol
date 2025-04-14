// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/BuzzSwapRouter.sol";
contract RedeployRouter is Script {

    address constant FACTORY_ADDRESS = 0x9cC87998ba85D81e017E6B7662aC00eE2Ab8fe13;

    function run() external {
        vm.startBroadcast();
        BuzzSwapRouter router = new BuzzSwapRouter(FACTORY_ADDRESS);
        console.log("BuzzSwapRouter:", address(router));
        vm.stopBroadcast();
    }
}