// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ItemNFT721} from "./ItemNFT721.sol";
import {MagicToken} from "./MagicToken.sol";

/**
 * @title Marketplace
 * @notice Lists crafted items for sale and settles purchases using Magic tokens.
 */
contract Marketplace is AccessControl {
    struct Listing {
        address seller;
        uint256 price;
    }

    ItemNFT721 public items;
    MagicToken public magic;

    mapping(uint256 => Listing) public listings;

    /// @param admin Address that receives the admin role for managing marketplace permissions.
    /// @param _items Contract that manages the item NFTs being sold.
    /// @param _magic ERC20 token contract used to settle trades.
    constructor(address admin, ItemNFT721 _items, MagicToken _magic) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        items = _items;
        magic = _magic;
    }

    /// @notice Lists an item for sale with the provided Magic token price.
    /// @param tokenId Identifier of the item being listed.
    /// @param price Magic token amount required to purchase the item.
    function list(uint256 tokenId, uint256 price) external {
        if (items.ownerOf(tokenId) != msg.sender) revert("Not item owner");
        if (price == 0) revert("Invalid price");
        if (listings[tokenId].seller != address(0)) revert("Already listed");

        listings[tokenId] = Listing({seller: msg.sender, price: price});

    }

    /// @notice Removes an active listing owned by the caller.
    /// @param tokenId Identifier of the item to delist.
    function delist(uint256 tokenId) external {
        Listing memory listing = listings[tokenId];
        if (listing.seller == address(0)) revert("Not listed");
        if (listing.seller != msg.sender) revert("Not listing owner");

        delete listings[tokenId];

    }

    /// @notice Executes a purchase, burning the item and settling Magic token transfers.
    /// @param tokenId Identifier of the listed item.
    function purchase(uint256 tokenId) external {
        Listing memory listing = listings[tokenId];
        if (listing.seller == address(0)) revert("Not listed");
        if (listing.seller == msg.sender) revert("Seller cannot purchase");
        if (items.ownerOf(tokenId) != listing.seller) revert("Seller not owner");

        delete listings[tokenId];

        magic.burnFrom(msg.sender, listing.price);
        magic.mint(listing.seller, listing.price);
        items.burn(tokenId);

    }
}
