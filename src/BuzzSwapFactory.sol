// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./BuzzSwapPair.sol";

contract BuzzSwapFactory {
    // Now includes bondingCurve in the key
    mapping(address => mapping(address => mapping(address => address))) public getPair;
    address[] public allPairs;

    address public feeTo;
    address public feeToSetter; // admin that decides who gets the fee

    mapping(address => address[]) public userPools;
    event PairCreated(address indexed token0, address indexed token1, address bondingCurve, address pair, uint);

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
        require(getPair[token0][token1][bondingCurve] == address(0), "BuzzSwap: PAIR_EXISTS");

        bytes memory bytecode = type(BuzzSwapPair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1, bondingCurve));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }

        BuzzSwapPair(pair).initialize(token0, token1, bondingCurve);
        getPair[token0][token1][bondingCurve] = pair;
        getPair[token1][token0][bondingCurve] = pair;

        allPairs.push(pair);
        emit PairCreated(token0, token1, bondingCurve, pair, allPairs.length);
    }

    function getSortedPair(address tokenA, address tokenB, address bondingCurve) external view returns (address) {
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        return getPair[token0][token1][bondingCurve];
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, "BuzzSwap: FORBIDDEN");
        feeTo = _feeTo;
    }

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

    function addUserPool(address user, address pair) external {
        userPools[user].push(pair);
    }
}