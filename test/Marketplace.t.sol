// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {BaseTest} from "./Base.t.sol";

import {ItemNFT721} from "../src/ItemNFT721.sol";

/**
 * @title MarketplaceTest
 * @notice Tests listing lifecycle and settlement logic for the marketplace.
 */
contract MarketplaceTest is BaseTest {
    function test_list_successfullyStoresListing() public {
        uint256 tokenId = _craftItem(ItemNFT721.ItemType.Saber);
        uint256 price = 25 ether;

        mkt.list(tokenId, price);

        (address seller, uint256 listingPrice) = mkt.listings(tokenId);
        assertEq(seller, address(this));
        assertEq(listingPrice, price);
    }

    function test_list_revertsForInvalidPrice() public {
        uint256 tokenId = _craftItem(ItemNFT721.ItemType.Saber);

        vm.expectRevert("Invalid price");
        mkt.list(tokenId, 0);
    }

    function test_list_revertsForNonOwner() public {
        uint256 tokenId = _craftItem(ItemNFT721.ItemType.Saber);

        vm.prank(otherAccount);
        vm.expectRevert("Not item owner");
        mkt.list(tokenId, 1 ether);
    }

    function test_list_revertsWhenAlreadyListed() public {
        uint256 tokenId = _craftItem(ItemNFT721.ItemType.Saber);

        mkt.list(tokenId, 1 ether);

        vm.expectRevert("Already listed");
        mkt.list(tokenId, 1 ether);
    }

    function test_delist_clearsListing() public {
        uint256 tokenId = _craftItem(ItemNFT721.ItemType.Saber);

        mkt.list(tokenId, 2 ether);
        mkt.delist(tokenId);

        (address seller, uint256 price) = mkt.listings(tokenId);
        assertEq(seller, address(0));
        assertEq(price, 0);
    }

    function test_delist_revertsForNonSeller() public {
        uint256 tokenId = _craftItem(ItemNFT721.ItemType.Saber);

        mkt.list(tokenId, 3 ether);

        vm.prank(otherAccount);
        vm.expectRevert("Not listing owner");
        mkt.delist(tokenId);
    }

    function test_delist_revertsWhenNotListed() public {
        uint256 tokenId = _craftItem(ItemNFT721.ItemType.Saber);

        vm.expectRevert("Not listed");
        mkt.delist(tokenId);
    }

    function test_purchase_executesSettlement() public {
        uint256 tokenId = _craftItem(ItemNFT721.ItemType.Saber);
        uint256 price = 5 ether;

        mkt.list(tokenId, price);

        vm.prank(address(mkt));
        magic.mint(otherAccount, price);

        assertEq(items.balanceOf(address(this)), 1);
        assertEq(magic.balanceOf(address(this)), 0);
        assertEq(magic.balanceOf(otherAccount), price);

        vm.startPrank(otherAccount);
        magic.approve(address(mkt), price);
        mkt.purchase(tokenId);
        vm.stopPrank();

        (address seller, uint256 storedPrice) = mkt.listings(tokenId);
        assertEq(seller, address(0));
        assertEq(storedPrice, 0);

        assertEq(magic.balanceOf(address(this)), price);
        assertEq(magic.balanceOf(otherAccount), 0);
        assertEq(magic.allowance(otherAccount, address(mkt)), 0);
        assertEq(items.balanceOf(address(this)), 0);
    }

    function test_purchase_revertsWhenSellerIsNotOwner() public {
        uint256 tokenId = _craftItem(ItemNFT721.ItemType.Saber);
        uint256 price = 7 ether;

        mkt.list(tokenId, price);

        items.safeTransferFrom(address(this), otherAccount, tokenId);

        address buyer = address(0xBEEF);
        vm.prank(address(mkt));
        magic.mint(buyer, price);

        vm.startPrank(buyer);
        magic.approve(address(mkt), price);
        vm.expectRevert("Seller not owner");
        mkt.purchase(tokenId);
        vm.stopPrank();

        (address seller, uint256 storedPrice) = mkt.listings(tokenId);
        assertEq(seller, address(this));
        assertEq(storedPrice, price);
    }

    function test_purchase_revertsWhenNotListed() public {
        vm.expectRevert("Not listed");
        mkt.purchase(123);
    }

    function test_purchase_revertsWhenSellerCalls() public {
        uint256 tokenId = _craftItem(ItemNFT721.ItemType.Saber);
        uint256 price = 9 ether;

        mkt.list(tokenId, price);

        vm.expectRevert("Seller cannot purchase");
        mkt.purchase(tokenId);
    }
}
