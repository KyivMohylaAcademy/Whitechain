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

    uint256 public constant MAGIC_AMOUNT = 100;

    constructor(address admin, ItemNFT721 _items, MagicToken _magic) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        items = _items;
        magic = _magic;
    }

    function sell(uint256 tokenId) external {
        require(msg.sender == items.ownerOf(tokenId), "Only owner can sell token");

        magic.mint(msg.sender, MAGIC_AMOUNT);
        items.burn(tokenId);
    }
}
