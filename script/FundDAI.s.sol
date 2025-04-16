// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract FundDAI is Script {
    address constant DAI  = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant DAI_WHALE = 0x604981db0C06Ea1b37495265EDa4619c8Eb95A3D;
    address constant RECIPIENT = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    function run() external {
        uint256 amount = 1_000_000 * 1e18;

        // This uses the whale address as tx.origin and msg.sender
        vm.startBroadcast(0x604981db0C06Ea1b37495265EDa4619c8Eb95A3D);

        IERC20(DAI).transfer(RECIPIENT, amount);
        console.log("Transferred 1,000,000 DAI to:", RECIPIENT);
        console.log(IERC20(DAI).balanceOf(RECIPIENT));
        vm.stopBroadcast();
    }
}