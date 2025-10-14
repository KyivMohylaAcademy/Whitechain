// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Item NFT (ERC721) for Kosak Business Game
/// @notice Represents unique crafted items like Sabre, Staff, Armor, Bracelet
/// @dev Minting is restricted to Crafting contract only

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ItemNFT721 is ERC721, Ownable {
    /// @notice Counter for token IDs
    uint256 private _tokenIdCounter;

    /// @notice Mapping allowed minters (Crafting contract)
    mapping(address => bool) public allowedMinters;

    /// @notice Struct describing item info
    struct ItemData {
        string name;
        string metadataURI;
    }

    /// @notice Mapping from token ID to item data
    mapping(uint256 => ItemData) public items;

    /// @notice Constructor assigns deployer as owner
    constructor() ERC721("KozakItem", "KITEM") Ownable(msg.sender) {}

    /// @notice Set contract that can mint items (Crafting)
    function setMinter(address minter, bool allowed) external onlyOwner {
        allowedMinters[minter] = allowed;
    }

    /// @notice Mint a new unique item (only from Crafting)
    function mintItem(address to, string memory name, string memory metadataURI)
        external
        returns (uint256)
    {
        require(allowedMinters[msg.sender], "Not allowed to mint");
        _tokenIdCounter++;
        uint256 newItemId = _tokenIdCounter;
        _safeMint(to, newItemId);

        items[newItemId] = ItemData(name, metadataURI);

        return newItemId;
    }

    /// @notice Burn an item (used by Marketplace when sold)
    function burnItem(uint256 tokenId) external {
        require(allowedMinters[msg.sender], "Not allowed to burn");
        _burn(tokenId);
        delete items[tokenId];
    }

    /// @notice Return metadata URI for a given token
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_ownerOf(tokenId) != address(0), "Item does not exist");
        return items[tokenId].metadataURI;
    }
}
