// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/BuzzSwapFactory.sol";
import "../src/bondingCurves/ConstantProductCurve.sol";
import "../src/bondingCurves/StableBondingCurve.sol";
import "../src/bondingCurves/ExponentialBondingCurve.sol";

contract CreatePools is Script {
    // === Placeholder addresses - fill these in before running ===
    address constant FACTORY = 0x18B458D6f2349b293C624693bEdcFfE15C49543e;          // BuzzSwapFactory address
    address constant CONSTANT_PRODUCT = 0xeAd4C2cc3c9c44be601373460BEe3c331FaFfe96; // ConstantProductCurve contract address
    address constant STABLE_CURVE = 0x0eC877d699e6996dAf44d5DfeA08B4FAb96CdB9a;     // StableCurve contract address
    address constant EXP_CURVE = 0xC0aBdd4dbc131B916AF8Fc448153F38aBe69E370;        // ExponentialCurve contract address

    address constant BUZZ  = 0xc993301287f7E7f7C0EB28c4616534CcAbA348BA;
    address constant USDC  = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant WETH  = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address constant DAI  = 0x6B175474E89094C44Da98b954EedeAC495271d0F;             // DAI token address

    function run() external {
        vm.startBroadcast();

        BuzzSwapFactory factory = BuzzSwapFactory(FACTORY);

        // 1. Deploy bonding curves
        // StableBondingCurve stable = new StableBondingCurve();
        // ExponentialBondingCurve exp = new ExponentialBondingCurve();

        console.log("Deployed ConstantProductCurve:", CONSTANT_PRODUCT);
        console.log("Deployed StableCurve:", STABLE_CURVE);
        console.log("Deployed ExponentialCurve:", EXP_CURVE);

        // 2. Create pairs
        _create(factory, WETH, BUZZ, CONSTANT_PRODUCT);
        _create(factory, WETH, BUZZ, EXP_CURVE);
        _create(factory, USDC, DAI, STABLE_CURVE);
        _create(factory, BUZZ, USDC, EXP_CURVE);
        _create(factory, WETH, DAI, CONSTANT_PRODUCT);
        _create(factory, BUZZ, DAI, CONSTANT_PRODUCT);
        _create(factory, BUZZ, DAI, STABLE_CURVE);
        _create(factory, USDC, WETH, EXP_CURVE);

        vm.stopBroadcast();
    }

    function _create(
        BuzzSwapFactory factory,
        address tokenA,
        address tokenB,
        address bondingCurve
    ) internal {
        address pair = factory.createPair(tokenA, tokenB, bondingCurve);
        console.log("Created pool:", tokenA, tokenB, pair);
    }
}