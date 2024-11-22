// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.28;

// Importing the Chainlink Aggregator interface to get the latest ETH/USD price
import "../lib/chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

// Interface for the token contract that includes the mint function
interface TokenInterface {
    function mint(address to, uint256 amount) external;
}

// Main contract for the Token ICO (Initial Coin Offering)
contract TokenICO {
    // Instance of the price feed interface to get the latest ETH/USD price
    AggregatorV3Interface internal priceFeed;
    // Instance of the token interface to mint tokens
    TokenInterface public minter;

    // Price of one token in USD (with two decimals)
    uint256 public tokenPrice = 100; // 1 token = 1 USD
    // Address of the contract owner
    address public owner;

    // Constructor to initialize the contract with the token address
    constructor(address tokenAddress) {
        // Set the price feed to the provided token address
        priceFeed = AggregatorV3Interface(tokenAddress);
        // Initialize the minter to the token address
        minter = TokenInterface(tokenAddress);
        // Set the contract owner to the address that deployed the contract
        owner = msg.sender;
    }

    // Function to get the latest ETH/USD price from Chainlink
    function getChainLinkLatestData() public view returns(int256) {
        // Fetch the latest round data from the price feed
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        return answer; // Return the latest price
    }

    // Function to calculate the amount of tokens a user will receive based on the ETH they send
    function tokenAmount(uint256 ethAmount) public view returns(uint256) {
        // Get the latest ETH/USD price
        uint256 ethUsd = uint256(getChainLinkLatestData()); // Price is in 8 decimals (e.g., 3930.00000000)
        // Calculate the USD value of the ETH sent
        uint256 amountUsd = (ethAmount * ethUsd) / 10**18;
        // Calculate the amount of tokens to be minted based on the USD value and token price
        uint256 amountToken = (amountUsd / tokenPrice) / 10 ** (8 / 2); // Adjust for decimals
        return amountToken; // Return the calculated token amount
    }

    // Fallback function to receive ETH and mint tokens
    receive() external payable {
        // Calculate the amount of tokens based on the ETH sent
        uint256 amountToken = tokenAmount(msg.value);
        // Mint the calculated amount of tokens to the sender's address
        minter.mint(msg.sender, amountToken);
    }

    // Modifier to restrict access to the contract owner
    modifier onlyOwner {
        require(msg.sender == owner, "Caller is not the owner"); // Check if the caller is the owner
        _; // Continue execution
    }

    // Function to withdraw the contract's balance, only callable by the owner
    function withdraw() public onlyOwner {
        // Transfer the entire balance of the contract to the owner
        payable(owner).transfer(address(this).balance);
    }
}