// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../interfaces/IBondingCurve.sol";

contract ExponentialBondingCurve is IBondingCurve {

    constructor() {}

    /**
     * Notes: exponential is computed as a Taylor series
     * @param amountIn amount to be swapped
     * @param reserveIn reserve of In Token
     * @param reserveOut reserve of out Token
     */
    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) external pure override returns (uint amountOut) {
        // Custom exponential model: increase output more steeply as reserveIn rises
        // This is a simplification: out = reserveOut * (1 - e^(-amountIn / reserveIn))
        // Approximate using Taylor series for e^x ~ 1 + x when x is small

        if (reserveIn == 0 || reserveOut == 0) return 0;

        uint ratio = (amountIn * 1e18) / reserveIn;

        // First-order approximation of (1 - e^(-x)) ~ x - x^2/2
        uint expApprox = ratio - (ratio * ratio) / (2 * 1e18); // 1e18 is a shorthand unit here

        amountOut = (reserveOut * expApprox) / 1e18; // 1e18 is a shorthand unit here
    }
}