// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";

import {ERC1155Holder} from "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import {ERC721Holder} from "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";

import {ResourceNFT1155} from "../src/ResourceNFT1155.sol";
import {ItemNFT721} from "../src/ItemNFT721.sol";
import {MagicToken} from "../src/MagicToken.sol";
import {CraftingSearch} from "../src/CraftingSearch.sol";
import {Marketplace} from "../src/Marketplace.sol";

contract TemplateTest is Test, ERC1155Holder, ERC721Holder {
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

    // TODO(student): add real tests as you implement features:
    // - search() cooldown + 3 random ERC1155 mints
    // - craft() recipes: burn ERC1155 + mint ERC721
    // - marketplace listing + purchase: burn ERC721 + mint MAGIC to seller

    function test_search() public {
        uint256 initResourceAmount = res.totalBalanceOf(address(this));
        cs.search();

        // assert cooldown works
        vm.expectRevert("Cooldown did not ended");
        cs.search();

        // assert correct number of resources
        uint256 resultResourceAmount = res.totalBalanceOf(address(this));
        assertTrue((initResourceAmount + 3) == resultResourceAmount, "Failed to recieve correct amount");
    }

    function _addResource(address to, uint256 resourceId, uint256 amount) private {
        vm.startPrank(address(cs));
        res.mint(to, resourceId, amount);
        vm.stopPrank();
    }

    function test_craft() public {
        _addResource(address(this), res.IRON(), 3);
        _addResource(address(this), res.WOOD(), 1);
        _addResource(address(this), res.LEATHER(), 1);

        uint256 initResourceAmount = res.totalBalanceOf(address(this));
        uint256 initItemCount = items.balanceOf(address(this));

        cs.craft(ItemNFT721.ItemType.Saber);

        // assert correct number of resources
        uint256 resultResourceAmount = res.totalBalanceOf(address(this));
        uint256 resultItemCount = items.balanceOf(address(this));

        assertTrue((initResourceAmount - 5) == resultResourceAmount, "Resources were not burned");
        assertTrue((initItemCount + 1) == resultItemCount, "Failed to recieve item");
    }

    function _craftItem(ItemNFT721.ItemType itemType) private returns (uint256) {
        if (itemType == ItemNFT721.ItemType.Saber) {
            _addResource(address(this), res.IRON(), 3);
            _addResource(address(this), res.WOOD(), 1);
            _addResource(address(this), res.LEATHER(), 1);

            return cs.craft(ItemNFT721.ItemType.Saber);
        } else if (itemType == ItemNFT721.ItemType.Staff) {
            // TODO fix
            vm.startPrank(address(cs));
            res.mint(address(this), res.IRON(), 3);
            res.mint(address(this), res.WOOD(), 1);
            res.mint(address(this), res.LEATHER(), 1);
            vm.stopPrank();

            return cs.craft(ItemNFT721.ItemType.Saber);
        }

        revert("Requested item type is not supported");
    }

    function test_valid_selling() public {
        uint256 tokenId = _craftItem(ItemNFT721.ItemType.Saber);

        uint256 initItemBalance = items.balanceOf(address(this));
        uint256 initMagicBalance = magic.balanceOf(address(this));

        mkt.sell(tokenId);

        uint256 resultItemBalance = items.balanceOf(address(this));
        uint256 resultMagicBalance = magic.balanceOf(address(this));

        assertTrue((initItemBalance - 1) == resultItemBalance, "Item was not burned");
        assertTrue((initMagicBalance + mkt.MAGIC_AMOUNT()) == resultMagicBalance, "Magic was not added");
    }

    function test_invalid_selling() public {
        uint256 tokenId = _craftItem(ItemNFT721.ItemType.Saber);

        uint256 initItemBalance = items.balanceOf(address(this));
        uint256 initMagicBalance = magic.balanceOf(address(this));

        vm.startPrank(otherAccount);

        vm.expectRevert("Only owner can sell token");
        mkt.sell(tokenId);

        vm.startPrank(otherAccount);

        uint256 resultItemBalance = items.balanceOf(address(this));
        uint256 resultMagicBalance = magic.balanceOf(address(this));

        assertTrue(initItemBalance == resultItemBalance, "Item was burned from the wrong account");
        assertTrue(initMagicBalance == resultMagicBalance, "Magic was added from the wrong account");
    }
}
