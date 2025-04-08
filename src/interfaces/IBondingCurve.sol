// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IBondingCurve {
    function getAmountOut(
        uint amountIn,
        uint reserveIn,
        uint reserveOut
    ) external view returns (uint amountOut);
}