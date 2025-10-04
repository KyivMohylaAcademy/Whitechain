// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {BaseTest} from "./Base.t.sol";

import {ItemNFT721} from "../src/ItemNFT721.sol";

/**
 * @title MarketplaceTest
 * @notice Tests Marketplace burn-for-reward behavior and authorization checks.
 */
contract MarketplaceTest is BaseTest {
    /// @notice Verifies that selling burns the NFT and credits Magic tokens.
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

    /// @notice Ensures non-owners cannot sell and balances remain unchanged.
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
