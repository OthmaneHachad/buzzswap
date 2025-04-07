// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/BuzzCoin.sol";

contract BuzzCoinTest is Test {
    BuzzCoin public buzz;
    address public alice = address(0xA11CE);
    address public bob = address(0xB0B);

    uint256 public initialSupply = 1_000_000 * 1e18;

    function setUp() public {
        buzz = new BuzzCoin(initialSupply);
    }

    function testInitialSupplyAssignedToDeployer() public {
        assertEq(buzz.totalSupply(), initialSupply);
        assertEq(buzz.balanceOf(address(this)), initialSupply);
    }

    function testTransferBuzzCoin() public {
        buzz.transfer(alice, 1000 * 1e18);
        assertEq(buzz.balanceOf(alice), 1000 * 1e18);
        assertEq(buzz.balanceOf(address(this)), initialSupply - 1000 * 1e18);
    }

    function testApproveAndTransferFrom() public {
        buzz.approve(bob, 500 * 1e18);
        vm.prank(bob);
        buzz.transferFrom(address(this), alice, 500 * 1e18);

        assertEq(buzz.balanceOf(alice), 500 * 1e18);
        assertEq(buzz.balanceOf(address(this)), initialSupply - 500 * 1e18);
    }

    function testFailTransferInsufficientBalance() public {
        vm.prank(alice);
        buzz.transfer(bob, 1); // alice has 0 BUZZ, so this should fail
    }

    function testFailTransferFromWithoutApproval() public {
        vm.prank(bob);
        buzz.transferFrom(address(this), alice, 1); // no allowance set
    }
}