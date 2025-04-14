// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/BuzzSwapRouter.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IWETH {
    function deposit() external payable;
    function approve(address spender, uint256 amount) external returns (bool);
}

contract AddLiquidityFromWhale is Script {
    address constant BUZZ  = 0x48288D0e3079A03f6EC1846554CFc58C2696Aaee;
    address constant USDC  = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant WETH  = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant ROUTER = 0x81a5186946ce055a5ceeC93cd97C7e7EDe7Da922;

    address constant USDC_WHALE = 0x37305B1cD40574E4C5Ce33f8e8306Be057fD7341;

    function run() external {
        vm.startBroadcast();

        // === Add ETH/BUZZ Liquidity as Default Anvil Address ===
        IWETH weth = IWETH(WETH);
        weth.deposit{value: 10 ether}();
        console.log("Wrapped 10 ETH to WETH");

        IERC20(WETH).approve(ROUTER, type(uint256).max);
        IERC20(BUZZ).approve(ROUTER, type(uint256).max);

        BuzzSwapRouter router = BuzzSwapRouter(ROUTER);

        router.addLiquidity(
            WETH,
            BUZZ,
            1 ether,
            1000 ether
        );
        console.log("Liquidity added to ETH/BUZZ");

        // Transfer BUZZ to the USDC whale to enable providing BUZZ liquidity
        bool success = IERC20(BUZZ).transfer(USDC_WHALE, 1000 ether);
        require(success, "BUZZ transfer to whale failed");
        console.log("Transferred 1000 BUZZ to USDC whale");

        vm.stopBroadcast();

        // === Add USDC/BUZZ Liquidity as USDC Whale ===
        vm.startBroadcast(USDC_WHALE);

        IERC20(USDC).approve(ROUTER, type(uint256).max);
        IERC20(BUZZ).approve(ROUTER, type(uint256).max);

        router.addLiquidity(
            USDC,
            BUZZ,
            1000 * 1e6,   // USDC
            1000 ether    // BUZZ
        );
        console.log("Liquidity added to USDC/BUZZ");

        vm.stopBroadcast();
    }
}