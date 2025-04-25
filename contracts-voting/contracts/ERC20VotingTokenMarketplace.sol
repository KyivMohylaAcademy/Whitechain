// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.24;

import "./ERC20VotingToken.sol";

/// @title ERC20VotingTokenMarketplace
/// @author Artem Tarasenko (@shabashab)
/// @notice Marketplace for buying and selling ERC20VotingToken tokens for Ether.
/// @dev Handles minting and burning of voting tokens, and manages token pricing.
contract ERC20VotingTokenMarketplace {
    /// @notice Number of decimals for wei (Ether's smallest unit).
    uint8 private constant WEI_DECIMALS = 18;

    /// @notice The ERC20VotingToken contract instance.
    ERC20VotingToken public votingToken;

    /// @notice Number of decimals for the voting token, basically a cache.
    uint8 private votingTokenDecimals;

    /// @notice Price of one voting token in wei.
    uint256 public votingTokenPrice;

    /// @notice Error thrown when the contract does not have enough Ether for a withdrawal.
    error MarketplaceInsufficientBalance();

    /// @notice Error thrown when the user sends insufficient Ether for purchasing tokens.
    /// @param actualValue The amount of Ether sent.
    /// @param requiredValue The required amount of Ether to complete the purchase.
    error InsufficientValue(uint256 actualValue, uint256 requiredValue);

    /// @notice Error thrown when the user tries to sell more tokens than they own.
    error InsufficientTokenBalance();

    /// @notice Deploys the marketplace contract.
    /// @param _votingTokenAddress The address of the ERC20VotingToken contract.
    /// @param _initialPrice The initial price of one voting token in wei.
    constructor(
        address _votingTokenAddress,
        uint256 _initialPrice
    ) {
        votingToken = ERC20VotingToken(_votingTokenAddress);
        votingTokenDecimals = votingToken.decimals();
        votingTokenPrice = _initialPrice;
    }

    /// @notice Buy voting tokens by sending Ether.
    /// @dev Mints the specified amount of tokens to the caller if enough Ether is sent.
    /// @param amount The number of voting tokens to purchase.
    /// @custom:reverts InsufficientValue if the sent Ether is less than the required amount.
    function purchaseTokens(uint256 amount) external payable {
        uint256 requiredValue = (amount * votingTokenPrice) / (10 ** votingTokenDecimals);

        if (msg.value < requiredValue) {
            revert InsufficientValue(msg.value, requiredValue);
        }

        votingToken.mint(msg.sender, amount);
    }

    /// @notice Sell voting tokens in exchange for Ether.
    /// @dev Burns the specified amount of tokens from the caller and sends Ether in return.
    /// @param amount The number of voting tokens to sell.
    /// @custom:reverts InsufficientTokenBalance if the caller does not have enough tokens.
    function sellTokens(uint256 amount) external {
        uint256 sellValue = (amount * (10 ** WEI_DECIMALS)) / votingTokenPrice;

        if (votingToken.balanceOf(msg.sender) < amount) {
            revert InsufficientTokenBalance();
        }

        votingToken.burn(msg.sender, amount);
        payable(msg.sender).transfer(sellValue);
    }

    /// @notice Accept Ether sent directly to the contract.
    /// @dev Allows the contract to receive plain Ether transfers.
    receive() external payable {}

    /// @notice Fallback function to accept Ether.
    /// @dev Allows the contract to receive Ether with data or unknown function calls.
    fallback() external payable {}
}
