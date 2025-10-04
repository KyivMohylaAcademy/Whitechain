// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ItemNFT721} from "./ItemNFT721.sol";
import {MagicToken} from "./MagicToken.sol";

/**
 * @title Marketplace
 * @notice Marketplace that lets item owners burn their tokens for a fixed MagicToken reward.
 */
contract Marketplace is AccessControl {
    ItemNFT721 public items;
    MagicToken public magic;

    uint256 public constant MAGIC_AMOUNT = 100;

    /// @param admin Address that receives the admin role for managing marketplace permissions.
    /// @param _items Contract that manages the item NFTs being sold.
    /// @param _magic ERC20 token contract used to reward sellers.
    constructor(address admin, ItemNFT721 _items, MagicToken _magic) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        items = _items;
        magic = _magic;
    }

    /// @notice Allows an item owner to burn their token in exchange for a flat MagicToken payout.
    /// @param tokenId Identifier of the item being sold and burned.
    function sell(uint256 tokenId) external {
        require(msg.sender == items.ownerOf(tokenId), "Only owner can sell token");

        magic.mint(msg.sender, MAGIC_AMOUNT);
        items.burn(tokenId);
    }
}
