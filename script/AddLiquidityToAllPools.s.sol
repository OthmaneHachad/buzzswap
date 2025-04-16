// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/BuzzSwapRouter.sol";
import "../src/BuzzSwapPair.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IWETH {
    function deposit() external payable;
    function approve(address spender, uint256 amount) external returns (bool);
}

interface IBuzzCoin is IERC20 {
    function mint(address to, uint256 amount) external;
}

contract AddLiquidityToAllPools is Script {
    address constant BUZZ  = 0xc993301287f7E7f7C0EB28c4616534CcAbA348BA;
    address constant USDC  = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant DAI   = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address constant WETH  = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant ROUTER = 0x38a264A473A182d988b0Ebe351Ef431cA5CCD3A7;

    address[] poolAddresses = [
        0xA1530A0A7799B1ea334deAD382c833FaE3610304,
        0x1f878EA1EF72C39a16cD1328334612d0d2486e6e,
        0xcFd33bDc823C45CC5898888F20c36915607C6Dc8,
        0x38c9f0e9E272AAE70E86B28bd69b553b208eB64D,
        0x7A8229Ff3fb9b4FA815cD73d8014dc5ac17E0bBA,
        0x73ECF8d4Fac6c3B24C0728EE7dAD4089ff193f07,
        0x3ce013DB2c5ac00F6CE187B994c410149983B09c,
        0x76590eDEC95079746E33B99BE18958ceDA184B1c
    ];

    function run() external {
        vm.startBroadcast();

        // Mint BUZZ tokens
        // IBuzzCoin(BUZZ).mint(msg.sender, 100_000 ether);
        // console.log("Minted 100,000 BUZZ to msg.sender");

        // Wrap ETH
        IWETH weth = IWETH(WETH);
        weth.deposit{value: 20 ether}();
        console.log("Wrapped 20 ETH to WETH");

        // Approvals
        IERC20(WETH).approve(ROUTER, type(uint256).max);
        IERC20(BUZZ).approve(ROUTER, type(uint256).max);
        IERC20(USDC).approve(ROUTER, type(uint256).max);
        IERC20(DAI).approve(ROUTER, type(uint256).max);
        console.log("Approved tokens for Router");

        BuzzSwapRouter router = BuzzSwapRouter(ROUTER);

        // Loop over pools
        for (uint i = 0; i < poolAddresses.length; i++) {
            address pairAddress = poolAddresses[i];
            BuzzSwapPair pair = BuzzSwapPair(pairAddress);

            address token0 = pair.getToken0();
            address token1 = pair.getToken1();
            address curve = pair.getBondingCurve();

            uint256 amount0 = getAmountForToken(token0);
            uint256 amount1 = getAmountForToken(token1);

            if (token0 == BUZZ || token1 == BUZZ) {
                amount0 = token0 == BUZZ ? 3_000 ether : amount0;
                amount1 = token1 == BUZZ ? 3_000 ether : amount1;
            }

            // Log before call
            console.log("Adding liquidity to Pool %s: %s", i + 1, pairAddress);
            console.log(" --> Token0: %s", token0);
            console.log(" --> Token1: %s", token1);
            console.log(" --> Amount0: %s", amount0);
            console.log(" --> Amount1: %s", amount1);

            // Add liquidity
            router.addLiquidity(token0, token1, curve, amount0, amount1);
            console.log("Liquidity added to Pool %s \n", i + 1);
        }

        vm.stopBroadcast();
    }

    function getAmountForToken(address token) internal pure returns (uint256) {
        if (token == USDC) return 2_000 * 1e6;
        if (token == DAI)  return 2_000 * 1e18;
        if (token == BUZZ) return 20_000 * 1e18;
        return 3 ether; // for WETH or fallback
    }
}