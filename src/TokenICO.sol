// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.28;
import "../lib/chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

interface TokenInterface{
    function mint(address to, uint256 amount) external;
}

contract TokenICO {
    AggregatorV3Interface internal priceFeed;
    TokenInterface public minter;

    uint256 public tokenPrice = 100; //1 token is 1 usd  with two decimals
    address public owner;

    constructor(address tokenAddress) {
        priceFeed = AggregatorV3Interface(tokenAddress);
    }
}