// SPDX-License-Identifier: MIT


pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IBondingCurve.sol";

contract BuzzSwapPair is ERC20 {
    address public token0;
    address public token1;
    IBondingCurve public bondingCurve;

    uint112 private reserve0;
    uint112 private reserve1;

    event Swap(
        address indexed sender,
        address indexed recipient,
        address tokenIn,
        address tokenOut,
        uint amountIn,
        uint amountOut
    );

    /**
     * this contract is getting deployed using create2(), so constructor remains argument-less
     */
    constructor() ERC20("Buzz LP Token", "BLP") {}

    /**
     * Only purpose is for deploying using create2 / assembly
     * @param _token0 token A
     * @param _token1 token B
     */
    function initialize(address _token0, address _token1, address _bondingCurve) external {
        require(token0 == address(0) && token1 == address(0), "Already initialized");
        token0 = _token0;
        token1 = _token1;
        bondingCurve = IBondingCurve(_bondingCurve);
    }


    function getReserves() public view returns (uint112, uint112) {
        return (reserve0, reserve1);
    }

    function _update(uint balance0, uint balance1) private {
        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
    }

    function addLiquidity(uint amount0, uint amount1, address recipient) external returns (uint liquidity) {

        uint _totalSupply = totalSupply();
        if (_totalSupply == 0) {
            liquidity = sqrt(amount0 * amount1);
        } else {
            liquidity = min(
                (amount0 * _totalSupply),
                (amount1 * _totalSupply)
            );
        }

        require(liquidity > 0, "Insufficient liquidity minted");
        _mint(recipient, liquidity); // mint LP Tokens

        _update(
            IERC20(token0).balanceOf(address(this)),
            IERC20(token1).balanceOf(address(this))
        );
    }

    function removeLiquidity(address from) external returns (uint amount0, uint amount1) {
        uint liquidity = balanceOf(address(this)); // returns number of LP tokens
        require(liquidity > 0,"nothing to burn");

        uint _totalSupply = totalSupply();

        amount0 = (liquidity * reserve0) / _totalSupply;
        amount1 = (liquidity * reserve1) / _totalSupply;

        _burn(address(this), liquidity);
        _update(reserve0 - amount0, reserve1 - amount1);

        IERC20(token0).transfer(from, amount0);
        IERC20(token1).transfer(from, amount1);
    }

    function swap(address tokenIn, address recipient) external returns (uint amountOut) {
        require(tokenIn == token0 || tokenIn == token1, "Invalid token");

        bool isToken0In = tokenIn == token0;
        (address tokenIn_, address tokenOut_, uint112 reserveIn, uint112 reserveOut) =
            isToken0In ? (token0, token1, reserve0, reserve1) : (token1, token0, reserve1, reserve0);

        // Now pull old reserve reserves
        (reserveIn, reserveOut) = isToken0In ? (reserve0, reserve1) : (reserve1, reserve0);

        // Add reserve sync before effectiveIn
        _update(
            IERC20(token0).balanceOf(address(this)),
            IERC20(token1).balanceOf(address(this))
        );
        uint balanceIn = IERC20(tokenIn_).balanceOf(address(this)); // = reserveIn + tokensIn
        uint effectiveIn = balanceIn - reserveIn;
        require(effectiveIn > 0, "swapping 0 tokens, aborting");

        amountOut = bondingCurve.getAmountOut(effectiveIn, reserveIn, reserveOut);

        require(amountOut > 0, "Insufficient output");
        // FIGURE THIS SHIT OUT
        /**
         * NO TOKENS ARE SHOWING IN THE msg.sender's WALLET
         * 
         */
        uint256 userBalanceOfTokenOutBefore = IERC20(tokenOut_).balanceOf(recipient);
        bool transferredTokenOutToUser = IERC20(tokenOut_).transfer(recipient, amountOut);
        require(transferredTokenOutToUser == true, "failed to send tokenOut to user");
        require(IERC20(tokenOut_).balanceOf(recipient) > userBalanceOfTokenOutBefore, "Balance of Token Out stayed unchanged");

        _update(
            IERC20(token0).balanceOf(address(this)),
            IERC20(token1).balanceOf(address(this))
        );
    }


    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }

    function getBondingCurve() external view returns (address) {
        return address(bondingCurve);
    }
    function getToken0() external view returns (address) {
        return token0;
    }
    function getToken1() external view returns (address) {
        return token1;
    }

}