// SPDX-License-Identifier: MIT


pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BuzzSwapPair is ERC20 {
    address public token0;
    address public token1;

    uint112 private reserve0;
    uint112 private reserve1;

    constructor(address _token0, address _token1) ERC20("Buzz LP Token", "BLP") {
        require(_token0 != _token1, "Identical Tokens");
        token0 = _token0;
        token1 = _token1;
    }

    /**
     * Only purpose is for deploying using create2 / assembly
     * @param _token0 token A
     * @param _token1 token B
     */
    function initialize(address _token0, address _token1) external {
        require(token0 == address(0) && token1 == address(0), "Already initialized");
        token0 = _token0;
        token1 = _token1;
    }

    function getReserves() public view returns (uint112, uint112) {
        return (reserve0, reserve1);
    }

    function _update(uint balance0, uint balance1) private {
        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
    }

    function addLiquidity(uint amount0, uint amount1) external returns (uint liquidity) {
        IERC20(token0).transferFrom(msg.sender, address(this), amount0);
        IERC20(token1).transferFrom(msg.sender, address(this), amount1);

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
        _mint(msg.sender, liquidity); // mint LP Tokens

        _update(
            IERC20(token0).balanceOf(address(this)),
            IERC20(token1).balanceOf(address(this))
        );
    }

    function removeLiquidity() external returns (uint amount0, uint amount1) {
        uint liquidity = balanceOf(msg.sender); // returns number of LP tokens
        require(liquidity > 0, "nothing to burn");

        uint _totalSupply = totalSupply();

        amount0 = (liquidity * reserve0) / _totalSupply;
        amount1 = (liquidity * reserve1) / _totalSupply;

        _burn(msg.sender, liquidity);
        _update(reserve0 - amount0, reserve1 - amount1);

        IERC20(token0).transfer(msg.sender, amount0);
        IERC20(token1).transfer(msg.sender, amount1);
    }

    function swap(uint amountIn, address tokenIn) external returns (uint amountOut) {
        require(tokenIn == token0 || tokenIn == token1, "Invalid token");

        bool isToken0In = tokenIn == token0;
        (address tokenIn_, address tokenOut_, uint112 reserveIn, uint112 reserveOut) =
            isToken0In ? (token0, token1, reserve0, reserve1) : (token1, token0, reserve1, reserve0);

        IERC20(tokenIn_).transferFrom(msg.sender, address(this), amountIn);

        uint balanceIn = IERC20(tokenIn_).balanceOf(address(this));
        uint balanceOut = IERC20(tokenOut_).balanceOf(address(this));

        uint amountInWithFee = (balanceIn - reserveIn) * 997; // 0.3% fee
        amountOut = (amountInWithFee * reserveOut) / (reserveIn * 1000 + amountInWithFee);

        require(amountOut > 0, "Insufficient output");
        IERC20(tokenOut_).transfer(msg.sender, amountOut);

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
}