// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../interfaces/IBondingCurve.sol";

contract StableCurve is IBondingCurve {

    uint256 public immutable A; // amplification coeff
    constructor(uint256 _A) {
        require(_A >= 1, "Ampliffcation factor must be >= 1");
        A = _A;
    }

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
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external view override returns (uint256 amountOut) {
        uint256 amountInWithFee = (amountIn * 999) / 1000;
        uint256 D = reserveIn + reserveOut;
        uint256 newReserveIn = reserveIn + amountInWithFee;

        uint256 weightedIn = newReserveIn * A;
        uint256 newReserveOut = (D * A * 1e18) / (weightedIn + A * 1e18);
        newReserveOut = newReserveOut / 1e18;

        if (newReserveOut > reserveOut) return 0;

        amountOut = reserveOut - newReserveOut;
    }

    /// @notice Computes StableSwap invariant D for 2-token pool
    function _getD(uint256 x, uint256 y, uint256 amp) internal pure returns (uint256 D) {
        D = x + y;
        for (uint256 i = 0; i < 255; ++i) {
            uint256 D_prev = D;
            D = ((2 * D * D) + amp * (x + y)) / ((3 * D) + amp);
            if (_abs(int256(D) - int256(D_prev)) <= 1) break;
        }
    }

    /// @notice Solves for new reserveOut y given x and invariant D
    function _getY(uint256 x, uint256 D, uint256 amp) internal pure returns (uint256 y) {
        y = D;
        for (uint256 i = 0; i < 255; ++i) {
            uint256 y_prev = y;
            uint256 denom = 2 * y + x + amp;
            uint256 k = (y * y + x * x) * amp;
            y = k / denom;
            if (_abs(int256(y) - int256(y_prev)) <= 1) break;
        }
    }

    function _abs(int256 x) internal pure returns (uint256) {
        return uint256(x >= 0 ? x : -x);
    }
}