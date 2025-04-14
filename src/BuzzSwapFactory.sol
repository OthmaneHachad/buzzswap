// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./BuzzSwapPair.sol";

contract BuzzSwapFactory {
    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs;

    address public feeTo;
    address public feeToSetter; // admin that decides who gets the fee

    

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    constructor(address _feeToSetter) {
        feeToSetter = _feeToSetter;
    }

    function createPair(address tokenA, address tokenB, address bondingCurve) external returns (address pair) {
        require(tokenA != tokenB, "BuzzSwap: IDENTICAL_ADDRESSES");
        require(bondingCurve != address(0), "BuzzSwap: INVALID_CURVE");

        (address token0, address token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);

        require(token0 != address(0), "BuzzSwap: ZERO_ADDRESS");
        require(getPair[token0][token1] == address(0), "BuzzSwap: PAIR_EXISTS");

        // ensures deterministic deployment - same token pair always gets the same contract address
        // note different pairs with different fees are deployed seperatly
        bytes memory bytecode = type(BuzzSwapPair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        BuzzSwapPair(pair).initialize(token0, token1, bondingCurve);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // enable reverse lookup

        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function getSortedPair(address tokenA, address tokenB) external view returns (address) {
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        return getPair[token0][token1];
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    /**
     * sets the address that collects the fees
     * @param _feeTo address that collects the fees
     */
    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, "BuzzSwap: FORBIDDEN");
        feeTo = _feeTo;
    }

    /**
     * allows changing the admin who controls the fees
     * @param _feeToSetter address that controls the fees
     */
    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, "BuzzSwap: FORBIDDEN");
        feeToSetter = _feeToSetter;
    }

    function getAllPairs() external view returns (address[] memory) {
        return allPairs;
    }

    function getFeeTo() external view returns (address) {
        return feeTo;
    }

    function getFeeToSetter() external view returns (address) {
        return feeToSetter;
    }
}