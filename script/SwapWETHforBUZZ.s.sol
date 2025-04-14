// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../src/BuzzSwapRouter.sol";

interface IWETH {
    function deposit() external payable;
    function approve(address spender, uint256 value) external returns (bool);
}

contract SwapWETHforBUZZ is Script {
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant BUZZ = 0x48288D0e3079A03f6EC1846554CFc58C2696Aaee;
    address constant ROUTER = 0xf3a7Aa52f75B5136668b9F2bf2f68606BDb2CDFA;
    address constant FACTORY = 0x0712629Ced85A3A62E5BCa96303b8fdd06CBF8dd;

    function run() external {
        vm.startBroadcast();

        address user = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
        require(msg.sender == user, "msg.sender doesn't match user addr 0x");
        uint256 amountIn = 7 ether;

        IERC20 wethToken = IERC20(WETH);
        IERC20 buzzToken = IERC20(BUZZ);

        // 0. Check Pair Funding
        BuzzSwapFactory factory = BuzzSwapFactory(FACTORY);
        address pair = factory.getSortedPair(WETH, BUZZ);
        require(pair != address(0), "Pair not created");
        console.log("Pair address:", pair);
        //require(pair == 0x7038DB98c063c0E1322BEAd1306DF17739294aca, "WETH/BUZZ Pool address mismatch");

        uint256 pairWETHBalance = wethToken.balanceOf(pair);
        uint256 pairBUZZBalance = buzzToken.balanceOf(pair);
        console.log("Pair WETH balance:", pairWETHBalance / 1e18);
        console.log("Pair BUZZ balance:", pairBUZZBalance / 1e18);
        require(pairWETHBalance > 0 && pairBUZZBalance > 0, "Pair not funded");

        // Pre-swap balances
        console.log("ETH before swap:", user.balance / 1e18);
        console.log("WETH before swap:", wethToken.balanceOf(user) / 1e18);
        console.log("BUZZ before swap:", buzzToken.balanceOf(user) / 1e18);

        // 1. Wrap ETH
        IWETH weth = IWETH(WETH);
        weth.deposit{value: amountIn}();
        console.log("Wrapped", amountIn / 1e18, "ETH to WETH");

        // 2. Approve Router to spend WETH
        wethToken.approve(ROUTER, amountIn);
        console.log("Approved WETH to Router");

        // 3. Call Router to swap WETH → BUZZ
        BuzzSwapRouter router = BuzzSwapRouter(ROUTER);
        uint256 buzzReceived = router.swapExactTokensForTokens(
            amountIn,
            WETH,
            BUZZ
        );

        console.log("Swapped:", amountIn / 1e18, "WETH to --> BUZZ", buzzReceived / 1e18);

        // Post-swap balances
        console.log("ETH after swap:", user.balance / 1e18);
        console.log("WETH after swap:", wethToken.balanceOf(msg.sender) / 1e18);
        console.log("BUZZ after swap:", buzzToken.balanceOf(msg.sender) / 1e18);

        console.log("Pair WETH balance:", wethToken.balanceOf(pair) / 1e18);
        console.log("Pair BUZZ balance:", buzzToken.balanceOf(pair) / 1e18);

        vm.stopBroadcast();
    }
}

