// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title RewardNFT
/// @notice ERC721 contract that mints NFTs as rewards for participating in votes
/// @dev Inherits from ERC721URIStorage and Ownable
contract RewardNFT is ERC721URIStorage, Ownable {
    uint256 private _tokenIds;

    /// @notice Constructor that sets token name and symbol, and initializes ownership
    constructor() ERC721("VotingRewardNFT", "VRNFT") Ownable(msg.sender) {}

    /// @notice Mints a new NFT to the specified address
    /// @dev Only callable by contract owner
    /// @param to Address to receive the NFT
    /// @return The ID of the newly minted token
    function mint(address to) external onlyOwner returns (uint256) {
        _tokenIds++;
        _mint(to, _tokenIds);
        _setTokenURI(_tokenIds, "ipfs://bafkreic5osrwbstpaixjrdoxciugj3fjw3zgnqvmm3zbvnqck7nngb6aaa");
        return _tokenIds;
    }
}
