// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/BuzzSwapRouter.sol";
import "../src/BuzzSwapFactory.sol";
import "../src/BuzzSwapPair.sol";
import "../src/bondingCurves/ConstantProductCurve.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IWETH is IERC20 {
    function deposit() external payable;
}

contract LiquidityCycleTest is Test {
    BuzzSwapFactory factory;
    BuzzSwapRouter router;
    ConstantProductCurve bondingCurve;

    address constant BUZZ = 0x48288D0e3079A03f6EC1846554CFc58C2696Aaee;
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    address user = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 userPrivateKey = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    BuzzSwapPair pair;

    function setUp() public {
        vm.createSelectFork("http://127.0.0.1:8545");
        vm.deal(user, 100 ether);

        bondingCurve = new ConstantProductCurve();
        factory = new BuzzSwapFactory(address(this));
        router = new BuzzSwapRouter(address(factory));

        address pairAddress = factory.createPair(WETH, BUZZ, address(bondingCurve));
        pair = BuzzSwapPair(pairAddress);

        // Fund user with WETH and BUZZ
        vm.startPrank(user);
        IWETH(WETH).deposit{value: 10 ether}();
        IERC20(BUZZ).transfer(user, 5000 ether); // assumes BUZZ is already in this contract
        vm.stopPrank();
    }

    function testAddAndPartialRemoveLiquidity() public {
        vm.startPrank(user);

        // Approve router
        IERC20(WETH).approve(address(router), type(uint256).max);
        IERC20(BUZZ).approve(address(router), type(uint256).max);

        // Add liquidity
        uint wethAmount = 10 ether;
        uint buzzAmount = 10000 ether;
        router.addLiquidity(WETH, BUZZ, wethAmount, buzzAmount);

        uint lpBalance = pair.balanceOf(user);
        assertGt(lpBalance, 0, "LP tokens should be minted");

        // Remove 50% of LP tokens
        uint burnAmount = lpBalance / 2;
        pair.approve(address(router), burnAmount);
        (uint amount0, uint amount1) = router.removeLiquidity(WETH, BUZZ, burnAmount);

        assertGt(amount0, 0, "WETH returned");
        assertGt(amount1, 0, "BUZZ returned");

        uint remaining = pair.balanceOf(user);
        assertEq(remaining, lpBalance - burnAmount, "LP tokens should be half burned");

        // Remove remaining LP tokens
        pair.approve(address(router), remaining);
        router.removeLiquidity(WETH, BUZZ, remaining);
        assertEq(pair.balanceOf(user), 0, "All LP tokens should be burned");

        vm.stopPrank();
    }
}