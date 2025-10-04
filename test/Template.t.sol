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

    function test_resources_contract_supports_interface() public view {
        assertTrue(res.supportsInterface(0xd9b67a26), "Resource contract does not support ERC1155");
    }

    function _addResource(address to, uint256 resourceId, uint256 amount) private {
        vm.startPrank(address(cs));
        res.mint(to, resourceId, amount);
        vm.stopPrank();
    }

    function _testItemCraft(ItemNFT721.ItemType expectedItemType, uint256 resourceAmounts) private {
        uint256 initResourceAmount = res.totalBalanceOf(address(this));
        uint256 initItemCount = items.balanceOf(address(this));

        uint256 itemId = cs.craft(expectedItemType);

        uint256 resultResourceAmount = res.totalBalanceOf(address(this));
        uint256 resultItemCount = items.balanceOf(address(this));
        ItemNFT721.ItemType itemType = items.items(itemId);

        assertTrue((initResourceAmount - resourceAmounts) == resultResourceAmount, "Resources were not burned");
        assertTrue((initItemCount + 1) == resultItemCount, "Failed to recieve item");
        assertTrue(itemType == expectedItemType, "Item is not of a correct type");
    }

    function test_craft_saber() public {
        _addResource(address(this), res.IRON(), 3);
        _addResource(address(this), res.WOOD(), 1);
        _addResource(address(this), res.LEATHER(), 1);

        _testItemCraft(ItemNFT721.ItemType.Saber, 5);
    }

    function test_craft_staff() public {
        _addResource(address(this), res.WOOD(), 2);
        _addResource(address(this), res.GOLD(), 1);
        _addResource(address(this), res.DIAMOND(), 1);

        _testItemCraft(ItemNFT721.ItemType.Staff, 4);
    }

    function test_craft_armor() public {
        _addResource(address(this), res.LEATHER(), 4);
        _addResource(address(this), res.IRON(), 2);
        _addResource(address(this), res.GOLD(), 1);

        _testItemCraft(ItemNFT721.ItemType.Armor, 7);
    }

    function test_craft_bracelet() public {
        _addResource(address(this), res.IRON(), 4);
        _addResource(address(this), res.GOLD(), 2);
        _addResource(address(this), res.DIAMOND(), 2);

        _testItemCraft(ItemNFT721.ItemType.Bracelet, 8);
    }

    function test_invalid_craft() public {
        _addResource(address(this), res.IRON(), 4);

        uint256 initResourceAmount = res.totalBalanceOf(address(this));
        uint256 initItemCount = items.balanceOf(address(this));

        vm.expectRevert("Not enough recources to craft item");
        cs.craft(ItemNFT721.ItemType.Saber);

        uint256 resultResourceAmount = res.totalBalanceOf(address(this));
        uint256 resultItemCount = items.balanceOf(address(this));

        assertTrue(initResourceAmount == resultResourceAmount, "Failed craft burned resources");
        assertTrue(initItemCount == resultItemCount, "Failed craft added item");
    }

    function _craftItem(ItemNFT721.ItemType itemType) private returns (uint256) {
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

    function test_items_contract_supports_interface() public view {
        assertTrue(items.supportsInterface(0x80ac58cd), "Item contract does not support ERC721");
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
