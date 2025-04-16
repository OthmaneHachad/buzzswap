// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FundUSDC is Script {
    address constant USDC  = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant WHALE = 0x37305B1cD40574E4C5Ce33f8e8306Be057fD7341;
    address constant RECIPIENT = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    function run() external {
        uint256 amount = 1_000_000 * 1e6;

        // This uses the whale address as tx.origin and msg.sender
        vm.startBroadcast(0x37305B1cD40574E4C5Ce33f8e8306Be057fD7341);

        IERC20(USDC).transfer(RECIPIENT, amount);
        console.log("Transferred 1,000,000 USDC to:", RECIPIENT);
        vm.stopBroadcast();
    }
}