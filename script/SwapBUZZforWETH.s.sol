// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../src/BuzzSwapRouter.sol";

interface IWETH {
    function deposit() external payable;
    function approve(address spender, uint256 value) external returns (bool);
}

contract SwapBUZZforWETH is Script {
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant BUZZ = 0x48288D0e3079A03f6EC1846554CFc58C2696Aaee;
    address constant ROUTER = 0xf3a7Aa52f75B5136668b9F2bf2f68606BDb2CDFA;

    function run() external {
        vm.startBroadcast();

        address user = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
        uint256 amountIn = 15_700 ether;

        IERC20 wethToken = IERC20(WETH);
        IERC20 buzzToken = IERC20(BUZZ);

        // Pre-swap balances
        uint256 wethBefore = wethToken.balanceOf(user);
        uint256 buzzBefore = buzzToken.balanceOf(user);

        console.log("WETH before swap:", wethBefore / 1e18);
        console.log("BUZZ before swap:", buzzBefore / 1e18);

        // Approve Router to spend BUZZ
        buzzToken.approve(ROUTER, amountIn);
        console.log("Approved BUZZ to Router");

        // Call Router to swap BUZZ → WETH
        BuzzSwapRouter router = BuzzSwapRouter(ROUTER);
        uint256 wethReceived = router.swapExactTokensForTokens(
            amountIn,
            BUZZ,
            WETH
        );

        console.log("Swapped:", amountIn / 1e18, "BUZZ to --> WETH", wethReceived / 1e18);

        // Post-swap balances
        uint256 wethAfter = wethToken.balanceOf(user);
        uint256 buzzAfter = buzzToken.balanceOf(user);

        console.log("WETH after swap:", wethAfter / 1e18);
        console.log("BUZZ after swap:", buzzAfter / 1e18);

        vm.stopBroadcast();
    }
}