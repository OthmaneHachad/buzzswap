// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/interfaces/IBondingCurve.sol";
import "../src/bondingCurves/ConstantProductCurve.sol";
import "../src/bondingCurves/ConstantSumCurve.sol";
import "../src/bondingCurves/StableCurve.sol";

contract BondingCurveTest is Test {
    IBondingCurve public constantProduct;
    IBondingCurve public constantSum;
    IBondingCurve public stable;

    uint256 public reserveIn = 1000 ether;
    uint256 public reserveOut = 1000 ether;

    function setUp() public {
        constantProduct = new ConstantProductCurve();
        constantSum = new ConstantSumCurve();
        stable = new StableCurve(100); // Amplification A = 100
    }

    function testConstantProductSwap() public {
        uint256 amountIn = 100 ether;
        uint256 amountOut = constantProduct.getAmountOut(amountIn, reserveIn, reserveOut);
        emit log_named_uint("Constant Product - Amount Out", amountOut);
        assertGt(amountOut, 0);
        assertLt(amountOut, amountIn); // should have slippage
    }

    function testConstantSumSwap() public {
        uint256 amountIn = 100 ether;
        uint256 amountOut = constantSum.getAmountOut(amountIn, reserveIn, reserveOut);
        emit log_named_uint("Constant Sum - Amount Out", amountOut);
        assertEq(amountOut, amountIn); // 1:1 rate, no slippage
    }

    //1000000000000000000000 > 100000000000000000000, is True?

    function testStableCurveSwap() public {
        uint256 amountIn = 100 ether;
        uint256 amountOut = stable.getAmountOut(amountIn, reserveIn, reserveOut);
        emit log_named_uint("Stable Curve - Amount Out", amountOut);
        assertGt(amountOut, 0);
        assertLe(amountOut, amountIn); // generally less than or equal to input
    }
}
