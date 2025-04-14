// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../interfaces/IBondingCurve.sol";

contract ConstantSumCurve is IBondingCurve {
    constructor() {}
    /**
     * Notes:
     *      - NO slippage
     *      - capital-inefficient
     *      - can be drained entirely
     *      - anything BUT industry standard
     * @param amountIn amount to be swapped
     * @param reserveIn reserve of In Token
     * @param reserveOut reserve of out Token
     */
    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) external pure override returns (uint amountOut) {
        require(amountIn <= reserveOut, "Insufficient liquidity");
        amountOut = amountIn; // Always 1:1, no fee/slippage
    }
}