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
        minter = TokenInterface(tokenAddress);

        owner = msg.sender;
    }

    //Returns the amount of the Latest Eth/Usd Price.
    function getChainLinkLatestData() public view returns(int256){
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        return answer;
    }

    //Returns the amount the user will get as accorrding to the ETh He/She Brought.
    function tokenAmount(uint256 ethAmount) public view returns(uint256){
        uint256 ethUsd = uint256(getChainLinkLatestData()); //will return in 8 decimals i.e 3930,00000000
        uint256 amountUsd = (ethAmount * ethUsd) / 10**18;
        uint256 amountToken = (amountUsd/tokenPrice)/ 10 **(8/2);
        return amountToken;
    }

    receive() external payable {
        uint256 amountToken = tokenAmount(msg.value);
        minter.mint(msg.sender, amountToken);
    }
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    function withdraw() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }


}