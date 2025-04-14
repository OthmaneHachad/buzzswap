// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "../interfaces/IBondingCurve.sol";

contract StableCurve is IBondingCurve {

    uint256 public immutable A; // amplification coeff
    constructor(uint256 _A) {
        require(_A >= 1, "Amplification factor must be >= 1");
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

        uint256 x = reserveIn + amountInWithFee;
        uint256 y = reserveOut;

        uint256 D = _getD(x, y, A);
        uint256 yNew = _getY(x, D, A);

        require(yNew <= y, "StableCurve: overflow");
        amountOut = y - yNew;
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
        uint256 Ann = amp * 2; // A * n^n, n = 2 tokens
        uint256 c = (D * D) / (x * 2); // D^2 / (x * 2)
        c = (c * D) / (Ann * 4);       // Scale c
        uint256 b = x + D / Ann;       // x + D / (A * n)

        y = D;
        for (uint256 i = 0; i < 255; ++i) {
            uint256 y_prev = y;
            uint256 numerator = y * y + c;
            uint256 denominator = (2 * y) + b - D;
            y = numerator / denominator;

            if (_abs(int256(y) - int256(y_prev)) <= 1) break;
        }
    }

    function _abs(int256 x) internal pure returns (uint256) {
        return uint256(x >= 0 ? x : -x);
    }
}