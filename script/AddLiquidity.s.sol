// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/BuzzSwapRouter.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IWETH {
    function deposit() external payable;
    function approve(address spender, uint256 amount) external returns (bool);
}

contract AddLiquidity is Script {
    address constant BUZZ  = 0x48288D0e3079A03f6EC1846554CFc58C2696Aaee;
    address constant USDC  = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant WETH  = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant ROUTER = 0xf3a7Aa52f75B5136668b9F2bf2f68606BDb2CDFA;

    address constant WHALE_USDC = 0x37305B1cD40574E4C5Ce33f8e8306Be057fD7341;
    address constant RECIPIENT = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;

    function run() external {

        // // Step 0: Impersonate whale + transfer USDC
        // uint256 fundAmount = 1_000_000 * 1e6;
        // vm.startPrank(WHALE_USDC);
        // IERC20(USDC).transfer(RECIPIENT, fundAmount);
        // vm.stopPrank();
        // console.log("Funded 1,000,000 USDC from whale");


        vm.startBroadcast();

        uint256 token0In = 15 ether; // shorthand unit
        uint256 token1In = 25_000 ether;

        // Step 2: Wrap 10 ETH → WETH
        IWETH weth = IWETH(WETH);
        weth.deposit{value: token0In}();
        console.log("Wrapped 15 ETH to WETH");

        // Step 3: Approve Router to spend tokens
        IERC20(WETH).approve(ROUTER, type(uint256).max);
        IERC20(BUZZ).approve(ROUTER, type(uint256).max);
        IERC20(USDC).approve(ROUTER, type(uint256).max);
        console.log("Approved WETH, BUZZ, and USDC to Router");

        // Log allowances
        console.log("USDC allowance:", IERC20(USDC).allowance(msg.sender, ROUTER));
        console.log("BUZZ allowance:", IERC20(BUZZ).allowance(msg.sender, ROUTER));

        BuzzSwapRouter router = BuzzSwapRouter(ROUTER);

        

        // Step 4: Provide liquidity to ETH/BUZZ (1 ETH, 1000 BUZZ)
        router.addLiquidity(
            WETH, 
            BUZZ,
            token0In,
            token1In
        );
        console.log("Provided ETH: ", token0In, " Provided Buzz: ", token1In);

        // uint256 senderUSDCBalance = IERC20(USDC).balanceOf(RECIPIENT);
        // uint256 senderBuzzBalance = IERC20(BUZZ).balanceOf(RECIPIENT);

        // console.log("sender has: ", senderUSDCBalance / 1e6, " USDC tokens");
        // console.log("sender has: ", senderBuzzBalance / 1e18, " Buzz tokens");

        // // Step 5: Provide liquidity to USDC/BUZZ (1000 USDC, 1000 BUZZ)
        // router.addLiquidity(
        //     USDC,
        //     BUZZ,
        //     1000 * 1e6,   // USDC is 6 decimals
        //     1000 ether    // BUZZ is 18 decimals
        // );
        // console.log("Liquidity added to USDC/BUZZ");

        vm.stopBroadcast();
    }
}