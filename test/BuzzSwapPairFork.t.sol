// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/BuzzSwapPair.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Create simple test tokens
contract MockERC20 is ERC20 {
    constructor(string memory name, string memory symbol, uint initialSupply) ERC20(name, symbol) {
        _mint(msg.sender, initialSupply);
    }
}

contract BuzzSwapPairForkTest is Test {
    BuzzSwapPair public pair;
    MockERC20 public tokenA;
    MockERC20 public tokenB;

    address public alice = address(0xA11CE);
    address public bob = address(0xB0B);
    uint public initialSupply = 1_000_000 * 1e18;

    function setUp() public {
        // Optional fork — you can skip this if using local mock tokens only
        vm.createSelectFork(vm.envString("SEPOLIA_RPC_URL"));

        tokenA = new MockERC20("BuzzCoin", "BUZZ", initialSupply);
        tokenB = new MockERC20("MockUSD", "MUSD", initialSupply);

        pair = new BuzzSwapPair(address(tokenA), address(tokenB));

        // Fund Alice and Bob
        tokenA.transfer(alice, 100_000 * 1e18);
        tokenB.transfer(alice, 100_000 * 1e18);

        vm.startPrank(alice);
        tokenA.approve(address(pair), type(uint).max);
        tokenB.approve(address(pair), type(uint).max);
        vm.stopPrank();
    }

    function testAddLiquidityAndSwap() public {
        vm.startPrank(alice);

        // Add liquidity: 10,000 BUZZ and 20,000 MUSD
        pair.addLiquidity(10_000 * 1e18, 20_000 * 1e18);
        (uint112 r0, uint112 r1) = pair.getReserves();

        assertEq(r0, 10_000 * 1e18);
        assertEq(r1, 20_000 * 1e18);

        // Swap 1000 BUZZ -> MUSD
        uint amountIn = 1_000 * 1e18;
        tokenA.approve(address(pair), amountIn);
        pair.swap(amountIn, address(tokenA)); // BUZZ in --> MUSD out

        (uint112 newR0, uint112 newR1) = pair.getReserves();
        assertGt(newR0, r0, "Reserve1 should increase after BUZZ --> MUSD swap");

        vm.stopPrank();
    }

    function testRemoveLiquidityReturnsCorrectAmounts() public {
        vm.startPrank(alice);

        // Step 1: Add liquidity
        uint amountA = 10_000 * 1e18;
        uint amountB = 20_000 * 1e18;

        pair.addLiquidity(amountA, amountB);

        uint lpBalanceBefore = pair.balanceOf(alice);
        assertGt(lpBalanceBefore, 0, "Alice should have LP tokens");

        // Step 2: Remove liquidity
        tokenA.approve(address(pair), type(uint).max);
        tokenB.approve(address(pair), type(uint).max);

        // Get token balances before removal
        uint buzzBefore = tokenA.balanceOf(alice);
        uint musdBefore = tokenB.balanceOf(alice);

        (uint amount0, uint amount1) = pair.removeLiquidity();

        // Check if Alice received tokens back
        uint buzzAfter = tokenA.balanceOf(alice);
        uint musdAfter = tokenB.balanceOf(alice);

        assertEq(buzzAfter, buzzBefore + amount0, "BuzzCoin returned");
        assertEq(musdAfter, musdBefore + amount1, "MockUSD returned");

        // LP token balance should be 0
        assertEq(pair.balanceOf(alice), 0, "All LP tokens should be burned");

        vm.stopPrank();
    }

}