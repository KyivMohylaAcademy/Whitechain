// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ItemNFT721} from "./ItemNFT721.sol";
import {MagicToken} from "./MagicToken.sol";

/**
 * @title Marketplace (Template)
 * @notice Minimal wiring only. No listings or purchase logic yet.
 *
 * TODO :
 * - Implement listing storage (tokenId => (seller, price)).
 * - Implement purchase:
 *   * (spec) burn item on sale and mint MagicToken to seller
 *   * or transfer then burn with a safe authorization flow
 */
contract Marketplace is AccessControl {
    ItemNFT721 public items;
    MagicToken public magic;

    struct Listing {
        address seller;
        uint256 price;
    }

    mapping (uint256 => Listing) public listings;

    constructor(address admin, ItemNFT721 _items, MagicToken _magic) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        items = _items;
        magic = _magic;
    }

    function list(uint256 tokenId, uint256 price) external {
        require(items.ownerOf(tokenId) == msg.sender, "Sender must be owner of the token");
        listings[tokenId] = Listing(msg.sender, price);
    }

    function delist(uint256 tokenId) external {
        Listing memory listing = listings[tokenId];
        require(listing.seller == msg.sender, "Delisting can only be done by the seller");

        delete listings[tokenId];
    }

    function purchase(uint256 tokenId) external {
        Listing memory listing = listings[tokenId];
        require(listing.seller != address(0), "The token is not listed for sale");
        require(items.ownerOf(tokenId) == listing.seller, "The seller is no longer the owner of the token");

        require(magic.balanceOf(msg.sender) >= listing.price, "Not enough MagicTokens for purchase");

        magic.transferFrom(msg.sender, listing.seller, listing.price);
        items.burn(tokenId);
    }
}
