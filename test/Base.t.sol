// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";

import {ERC1155Holder} from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

import {ResourceNFT1155} from "../src/ResourceNFT1155.sol";
import {ItemNFT721} from "../src/ItemNFT721.sol";
import {MagicToken} from "../src/MagicToken.sol";
import {CraftingSearch} from "../src/CraftingSearch.sol";
import {Marketplace} from "../src/Marketplace.sol";

contract BaseTest is Test, ERC1155Holder, ERC721Holder {
    ResourceNFT1155 res;
    ItemNFT721 items;
    MagicToken magic;
    CraftingSearch cs;
    Marketplace mkt;

    address admin = address(0xA11CE);
    address otherAccount = address(0x123);

    function setUp() public {
        // set time
        vm.warp(1_700_000_000);

        res = new ResourceNFT1155(admin);
        items = new ItemNFT721(admin);
        magic = new MagicToken(admin);
        cs = new CraftingSearch(admin, res, items);
        mkt = new Marketplace(admin, items, magic);

        // wire roles (mirrors Deploy.s.sol)
        vm.startPrank(admin);
        res.grantRole(res.MINTER_ROLE(), address(cs));
        res.grantRole(res.BURNER_ROLE(), address(cs));
        items.grantRole(items.MINTER_ROLE(), address(cs));
        items.grantRole(items.BURNER_ROLE(), address(mkt));
        magic.grantRole(magic.MARKET_ROLE(), address(mkt));
        vm.stopPrank();
    }

    function test_deployed_and_roles_wired() public view {
        // contracts deployed
        assertTrue(address(res) != address(0));
        assertTrue(address(items) != address(0));
        assertTrue(address(magic) != address(0));
        assertTrue(address(cs) != address(0));
        assertTrue(address(mkt) != address(0));

        // core roles wired
        assertTrue(res.hasRole(res.MINTER_ROLE(), address(cs)));
        assertTrue(res.hasRole(res.BURNER_ROLE(), address(cs)));
        assertTrue(items.hasRole(items.MINTER_ROLE(), address(cs)));
        assertTrue(magic.hasRole(magic.MARKET_ROLE(), address(mkt)));
    }

    function _addResource(address to, uint256 resourceId, uint256 amount) internal {
        vm.startPrank(address(cs));
        res.mint(to, resourceId, amount);
        vm.stopPrank();
    }

    function _craftItem(ItemNFT721.ItemType itemType) internal returns (uint256) {
        if (itemType == ItemNFT721.ItemType.Saber) {
            _addResource(address(this), res.IRON(), 3);
            _addResource(address(this), res.WOOD(), 1);
            _addResource(address(this), res.LEATHER(), 1);

            return cs.craft(ItemNFT721.ItemType.Saber);
        } else if (itemType == ItemNFT721.ItemType.Staff) {
            _addResource(address(this), res.WOOD(), 2);
            _addResource(address(this), res.GOLD(), 1);
            _addResource(address(this), res.DIAMOND(), 1);

            return cs.craft(ItemNFT721.ItemType.Staff);
        } else if (itemType == ItemNFT721.ItemType.Armor) {
            _addResource(address(this), res.LEATHER(), 4);
            _addResource(address(this), res.IRON(), 2);
            _addResource(address(this), res.GOLD(), 1);

            return cs.craft(ItemNFT721.ItemType.Staff);
        } else if (itemType == ItemNFT721.ItemType.Bracelet) {
            _addResource(address(this), res.IRON(), 4);
            _addResource(address(this), res.GOLD(), 2);
            _addResource(address(this), res.DIAMOND(), 2);

            return cs.craft(ItemNFT721.ItemType.Bracelet);
        }

        revert("Requested item type is not supported");
    }
}
