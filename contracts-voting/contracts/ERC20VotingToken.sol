// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC20VotingToken is ERC20, Ownable {
  address public marketplaceAddress;

  error UnauthorizedAccount();

  constructor(
    string memory name,
    string memory symbol
  ) ERC20(name, symbol) Ownable(_msgSender()) { }

  function setMarketplaceAddress(address _marketplaceAddress) external onlyOwner {
    marketplaceAddress = _marketplaceAddress;
  }

  function mint(address to, uint256 amount) external onlyMarketplace {
    _mint(to, amount);
  }

  function burn(address from, uint256 amount) external onlyMarketplace {
    _burn(from, amount);
  }

  modifier onlyMarketplace {
    if(_msgSender() != marketplaceAddress) {
      revert UnauthorizedAccount();
    }
    _;
  }
}