// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title MagicToken (ERC20) forKosak Business Game
/// @notice Game currency, mintable only by Marketplace contract
/// @dev Direct minting by players is forbidden

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MagicToken is ERC20, Ownable {
    /// @notice Mapping of allowed minters (only Marketplace)
    mapping(address => bool) public allowedMinters;

    /// @notice Constructor that assigns deployer as owner
    constructor() ERC20("MagicToken", "MAGIC") Ownable(msg.sender) {}

    /// @notice Set allowed minter (e.g., Marketplace contract)
    /// @param minter Address of the contract
    /// @param allowed true to allow minting, false to revoke
    function setMinter(address minter, bool allowed) external onlyOwner {
        allowedMinters[minter] = allowed;
    }

    /// @notice Mint new tokens (only callable by allowed minters)
    /// @param to Address to receive tokens
    /// @param amount Amount to mint (in wei)
    function mint(address to, uint256 amount) external {
        require(allowedMinters[msg.sender], "Not allowed to mint");
        _mint(to, amount);
    }
}
