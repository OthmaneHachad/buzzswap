// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./BuzzSwapFactory.sol";
import "./BuzzSwapPair.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BuzzSwapRouter {
    BuzzSwapFactory public factory;

    constructor(address _factory) {
        factory = BuzzSwapFactory(_factory);
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        address bondingCurve,
        uint amountA,
        uint amountB
    ) external returns (uint liquidity) {
        address pair = factory.getSortedPair(tokenA, tokenB, bondingCurve);
        require(pair != address(0), "invalid pool address");
        // if (pair == address(0)) {
        //     pair = factory.createPair(tokenA, tokenB,);
        // }

        IERC20(tokenA).transferFrom(msg.sender, pair, amountA);
        IERC20(tokenB).transferFrom(msg.sender, pair, amountB);

        liquidity = BuzzSwapPair(pair).addLiquidity(amountA, amountB, msg.sender);
        factory.addUserPool(msg.sender, pair);
    }

    function removeLiquidity(
        address tokenA,
        address tokenB,
        address bondingCurve,
        uint liquidityAmount
    ) external returns (uint amount0, uint amount1) {
        address pair = factory.getSortedPair(tokenA, tokenB, bondingCurve);
        require(pair != address(0), "BuzzSwapRouter: PAIR_NOT_EXIST");

        IERC20(pair).transferFrom(msg.sender, pair, liquidityAmount);
        (amount0, amount1) = BuzzSwapPair(pair).removeLiquidity(liquidityAmount, msg.sender);
    }

    function swapExactTokensForTokens(
        uint amountIn,
        address tokenIn,
        address tokenOut,
        address bondingCurve
    ) external returns (uint amountOut) {
        address pair = factory.getSortedPair(tokenIn, tokenOut, bondingCurve);
        require(pair != address(0), "BuzzSwapRouter: PAIR_NOT_EXIST");

        bool transferUserFundsToPair = IERC20(tokenIn).transferFrom(msg.sender, pair, amountIn);
        require(transferUserFundsToPair == true, "transfer of tokenIn from user's wallet failed");
        amountOut = BuzzSwapPair(pair).swap(tokenIn, msg.sender);
    }

    function getPairAddress(address tokenA, address tokenB, address bondingCurve) external view returns (address) {
        return factory.getSortedPair(tokenA, tokenB, bondingCurve);
    }

    function getFactory() external view returns (address) {
        return address(factory);
    }
}