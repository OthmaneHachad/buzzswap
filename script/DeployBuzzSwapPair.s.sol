// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/BuzzSwapPair.sol";

contract DeployBuzzSwapPair is Script {
    address constant TOKEN0 = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // WETH
    address constant TOKEN1 = 0x48288D0e3079A03f6EC1846554CFc58C2696Aaee; // BUZZ
    address constant CURVE = 0x74Ce26A2e4c1368C48A0157CE762944d282896Db; // ConstantProductCurve

    function run() external {
        vm.startBroadcast();

        BuzzSwapPair pair = new BuzzSwapPair();
        pair.initialize(TOKEN0, TOKEN1, CURVE);
        console.log("BuzzSwapPair deployed at:", address(pair));

        vm.stopBroadcast();
    }
}
