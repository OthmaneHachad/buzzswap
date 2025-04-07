// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";

contract SepoliaForkTest is Test {
    address constant exampleSepoliaAccount = 0x1234567890123456789012345678901234567890;

    function setUp() public {
        // Fork Sepolia at latest block
        vm.createSelectFork(vm.envString("SEPOLIA_RPC_URL"));
    }

    function testReadBalanceFromForkedSepolia() public view {
        uint256 balance = exampleSepoliaAccount.balance;
        console.log("ETH balance:", balance);
        assert(balance >= 0); // Always true, just demo
    }
}