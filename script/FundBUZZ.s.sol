// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IBuzzCoin is IERC20 {
    function mint(address to, uint256 amount) external;
}

contract FundBUZZ is Script {
    address constant BUZZ = 0x48288D0e3079A03f6EC1846554CFc58C2696Aaee;
    address constant RECIPIENT = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    function run() external {
        vm.startBroadcast();

        uint256 amount = 100_000 ether;
        IBuzzCoin(BUZZ).mint(RECIPIENT, amount);

        console.log("Minted %s BUZZ tokens to %s", amount / 1e18, RECIPIENT);

        vm.stopBroadcast();
    }
}