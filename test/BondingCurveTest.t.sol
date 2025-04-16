// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../../src/bondingCurves/ConstantProductCurve.sol";
import "../../src/bondingCurves/StableBondingCurve.sol";
import "../../src/bondingCurves/ExponentialBondingCurve.sol";

contract BondingCurveTest is Test {
    ConstantProductCurve constantProduct;
    StableBondingCurve stable;
    ExponentialBondingCurve exponential;

    function setUp() public {
        constantProduct = new ConstantProductCurve();
        stable = new StableBondingCurve();
        exponential = new ExponentialBondingCurve();
    }

    function testConstantProductOutputs() public {
        uint reserveIn = 1000 ether;
        uint reserveOut = 1000 ether;
        uint amountIn = 10 ether;

        uint amountOut = constantProduct.getAmountOut(amountIn, reserveIn, reserveOut);
        emit log_named_uint("Constant Product output:", amountOut);

        assertGt(amountOut, 0);
        assertLt(amountOut, amountIn); // there should be some slippage
    }

    function testStableOutputs_SmallTrade() public {
        uint reserveIn = 1000 ether;
        uint reserveOut = 1000 ether;
        uint amountIn = 5 ether; // small trade < 10%

        uint amountOut = stable.getAmountOut(amountIn, reserveIn, reserveOut);
        emit log_named_uint("Stable output (small trade):", amountOut);

        assertEq(amountOut, amountIn); // no slippage
    }

    function testStableOutputs_LargeTrade() public {
        uint reserveIn = 1000 ether;
        uint reserveOut = 1000 ether;
        uint amountIn = 150 ether; // large trade > 10%

        uint amountOut = stable.getAmountOut(amountIn, reserveIn, reserveOut);
        emit log_named_uint("Stable output (large trade):", amountOut);

        assertLt(amountOut, amountIn); // should incur slippage
    }

    function testExponentialOutputs() public {
        uint reserveIn = 1000 ether;
        uint reserveOut = 1000 ether;
        uint amountIn = 10 ether;

        uint amountOut = exponential.getAmountOut(amountIn, reserveIn, reserveOut);
        emit log_named_uint("Exponential output:", amountOut);

        assertGt(amountOut, 0);
    }
}
