// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.24;

import "./ERC20VotingToken.sol";

contract ERC20VotingTokenMarketplace {
  uint8 private constant WEI_DECIMALS = 18;

  ERC20VotingToken public votingToken;
  uint8 private votingTokenDecimals;

  uint256 public votingTokenPrice;

  error MarketplaceInsufficientBalance();
  error InsufficientValue(uint256 actualValue, uint256 requiredValue);
  error InsufficientTokenBalance();

  constructor(
    address _votingTokenAddress,
    uint256 _initialPrice
  ) {
    votingToken = ERC20VotingToken(_votingTokenAddress);
    votingTokenDecimals = votingToken.decimals();
    votingTokenPrice = _initialPrice;
  }

  function purchaseTokens(uint256 amount) external payable {
    uint256 requiredValue = (amount * votingTokenPrice) / (10 ** votingTokenDecimals);

    if (msg.value < requiredValue) {
      revert InsufficientValue(amount, requiredValue);
    }

    votingToken.mint(msg.sender, amount);
  }

  function sellTokens(uint256 amount) external {
    uint256 sellValue = (amount * (10 ** WEI_DECIMALS)) / votingTokenPrice;

    if(votingToken.balanceOf(msg.sender) < amount) {
      revert InsufficientTokenBalance();
    }

    votingToken.burn(msg.sender, amount);
    payable(msg.sender).transfer(sellValue);
  }

  receive() external payable {}
  fallback() external payable {}
}