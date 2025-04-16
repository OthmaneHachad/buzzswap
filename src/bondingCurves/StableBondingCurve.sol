// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../interfaces/IBondingCurve.sol";

contract StableBondingCurve is IBondingCurve {


    /**
     * Notes: implementation is an approximation of the actual bonding curve
     *      - when amountIn < 10% of reserveIn, behaves like 1:1
     *      - when amountIn >= 10% of reserveIn, behaves like constant product
     * @param amountIn amount to be swapped
     * @param reserveIn reserve of In Token
     * @param reserveOut reserve of out Token
     */
    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) external pure override returns (uint amountOut) {
        // Constant sum for small trades, constant product fallback for larger trades
        if (amountIn < reserveIn / 10) {
            // Treat as stable - near 1:1 with very little slippage
            return amountIn;
        } else {
            // Use Uniswap-style constant product as fallback
            uint amountInWithFee = amountIn * 997;
            uint numerator = amountInWithFee * reserveOut;
            uint denominator = reserveIn * 1000 + amountInWithFee;
            return numerator / denominator;
        }
    }
    
}