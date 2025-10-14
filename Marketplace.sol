// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Marketplace for Kosak Business Game
/// @notice Allows players to sell crafted items for MagicToken
/// @dev Handles token transfers and item burning upon sale

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ItemNFT721.sol";
import "./MagicToken.sol";

contract Marketplace is Ownable {
    struct Listing {
        address seller;
        uint256 price;
        bool active;
    }

    /// @notice References to item and token contracts
    ItemNFT721 public itemContract;
    MagicToken public magicToken;

    /// @notice Mapping from item ID to listing
    mapping(uint256 => Listing) public listings;

    event ItemListed(uint256 indexed itemId, address indexed seller, uint256 price);
    event ItemSold(uint256 indexed itemId, address indexed buyer, uint256 price);
    event ListingCancelled(uint256 indexed itemId);

    /// @notice Initialize marketplace with linked contracts
    constructor(address _itemContract, address _magicToken) Ownable(msg.sender) {
        itemContract = ItemNFT721(_itemContract);
        magicToken = MagicToken(_magicToken);
    }

    /// @notice List an item for sale
    /// @param itemId Token ID of the item
    /// @param price Price in MagicToken (wei)
    function listItem(uint256 itemId, uint256 price) external {
        require(price > 0, "Price must be positive");
        require(itemContract.ownerOf(itemId) == msg.sender, "Not item owner");

        listings[itemId] = Listing(msg.sender, price, true);

        // Approve Marketplace to transfer the item
        itemContract.approve(address(this), itemId);

        emit ItemListed(itemId, msg.sender, price);
    }

    /// @notice Buy an item using MagicToken
    /// @param itemId ID of the listed item
    function buyItem(uint256 itemId) external {
        Listing memory listing = listings[itemId];
        require(listing.active, "Item not listed");

        // Transfer tokens from buyer to seller
        require(
            magicToken.transferFrom(msg.sender, listing.seller, listing.price),
            "Token transfer failed"
        );

        // Burn the item (Marketplace has permission)
        itemContract.burnItem(itemId);

        // Mint same amount of MagicToken to buyer (reward system optional)
        // magicToken.mint(msg.sender, 1e18); // Uncomment if you want buyer rewards

        listings[itemId].active = false;
        emit ItemSold(itemId, msg.sender, listing.price);
    }

    /// @notice Cancel a listing (only seller)
    function cancelListing(uint256 itemId) external {
        Listing memory listing = listings[itemId];
        require(listing.seller == msg.sender, "Not your listing");
        require(listing.active, "Already inactive");

        listings[itemId].active = false;
        emit ListingCancelled(itemId);
    }
}
