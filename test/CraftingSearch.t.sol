// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {BaseTest} from "./Base.t.sol";

import {ItemNFT721} from "../src/ItemNFT721.sol";

/**
 * @title CraftingSearchTest
 * @notice Tests CraftingSearch resource searches and crafting recipes.
 */
contract CraftingSearch is BaseTest {
    /// @notice Ensures `search` mints three resources and enforces the cooldown per address.
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

    /// @dev Helper validating resource burns and minted item type for a given recipe.
    /// @param expectedItemType Item type expected from crafting.
    /// @param resourceAmounts Total resource units that should be deducted.
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

    /// @notice Confirms Saber crafting consumes recipe resources and mints the NFT.
    function test_craft_saber() public {
        _addResource(address(this), res.IRON(), 3);
        _addResource(address(this), res.WOOD(), 1);
        _addResource(address(this), res.LEATHER(), 1);

        _testItemCraft(ItemNFT721.ItemType.Saber, 5);
    }

    /// @notice Confirms Staff crafting consumes recipe resources and mints the NFT.
    function test_craft_staff() public {
        _addResource(address(this), res.WOOD(), 2);
        _addResource(address(this), res.GOLD(), 1);
        _addResource(address(this), res.DIAMOND(), 1);

        _testItemCraft(ItemNFT721.ItemType.Staff, 4);
    }

    /// @notice Confirms Armor crafting consumes recipe resources and mints the NFT.
    function test_craft_armor() public {
        _addResource(address(this), res.LEATHER(), 4);
        _addResource(address(this), res.IRON(), 2);
        _addResource(address(this), res.GOLD(), 1);

        _testItemCraft(ItemNFT721.ItemType.Armor, 7);
    }

    /// @notice Confirms Bracelet crafting consumes recipe resources and mints the NFT.
    function test_craft_bracelet() public {
        _addResource(address(this), res.IRON(), 4);
        _addResource(address(this), res.GOLD(), 2);
        _addResource(address(this), res.DIAMOND(), 2);

        _testItemCraft(ItemNFT721.ItemType.Bracelet, 8);
    }

    /// @notice Ensures crafting fails without the full recipe and leaves balances untouched.
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
}
