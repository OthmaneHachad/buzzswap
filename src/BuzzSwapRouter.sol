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
        uint amountA,
        uint amountB
    ) external returns (uint liquidity) {
        address pair = factory.getPair(tokenA, tokenB);
        if (pair == address(0)) {
            pair = factory.createPair(tokenA, tokenB);
        }

        IERC20(tokenA).transferFrom(msg.sender, pair, amountA);
        IERC20(tokenB).transferFrom(msg.sender, pair, amountB);

        liquidity = BuzzSwapPair(pair).addLiquidity(amountA, amountB);
    }

    function removeLiquidity(
        address tokenA,
        address tokenB
    ) external returns (uint amount0, uint amount1) {
        address pair = factory.getPair(tokenA, tokenB);
        require(pair != address(0), "BuzzSwapRouter: PAIR_NOT_EXIST");

        IERC20(pair).transferFrom(msg.sender, pair, IERC20(pair).balanceOf(msg.sender));
        (amount0, amount1) = BuzzSwapPair(pair).removeLiquidity();
    }

    function swapExactTokensForTokens(
        uint amountIn,
        address tokenIn,
        address tokenOut
    ) external returns (uint amountOut) {
        address pair = factory.getPair(tokenIn, tokenOut);
        require(pair != address(0), "BuzzSwapRouter: PAIR_NOT_EXIST");

        IERC20(tokenIn).transferFrom(msg.sender, pair, amountIn);
        amountOut = BuzzSwapPair(pair).swap(amountIn, tokenIn);
    }

    function getPairAddress(address tokenA, address tokenB) external view returns (address) {
        return factory.getPair(tokenA, tokenB);
    }
}