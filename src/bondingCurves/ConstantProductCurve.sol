// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../interfaces/IBondingCurve.sol";

contract ConstantProductCurve is IBondingCurve {
    /**
     * Notes:
     *      - highly responsive to imbalance (slippage)
     *      - industry standard
     * 
     * 
     * @param amountIn amount to be swapped
     * @param reserveIn reserve of In Token
     * @param reserveOut reserve of out Token
     */
    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) external pure override returns (uint amountOut) {
        uint amountInWithFee = amountIn * 997;
        amountOut = (amountInWithFee * reserveOut) / (reserveIn * 1000 + amountInWithFee);
    }
}