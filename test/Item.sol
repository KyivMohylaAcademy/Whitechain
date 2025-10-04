// SPDX-License-Identifier: MIT
pragma solidity ~0.8.25;

import "forge-std/Test.sol";
import "../src/Item.sol";

contract ItemTest is Test {
    Item public item;
    address public owner = address(1);
    address public itemCrafting = address(2);
    address public marketplace = address(3);
    address public user1 = address(4);
    address public user2 = address(5);

    function setUp() public {
        vm.prank(owner);
        item = new Item(owner);
        
        vm.startPrank(owner);
        item.setItemCraftingContract(itemCrafting);
        item.setMarketplaceContract(marketplace);
        vm.stopPrank();
    }

    function test_Constructor_SetsOwner() public view {
        assertEq(item.owner(), owner);
    }

    function test_Constructor_SetsNameAndSymbol() public view {
        assertEq(item.name(), "Item");
        assertEq(item.symbol(), "IM");
    }

    function test_MintItem_Success() public {
        vm.prank(itemCrafting);
        item.mintItem(user1, Item.Type.SABLE);
        
        assertEq(item.ownerOf(1), user1);
    }

    function test_MintItem_MintsMultipleItems() public {
        vm.startPrank(itemCrafting);
        item.mintItem(user1, Item.Type.SABLE);
        item.mintItem(user1, Item.Type.ELDERS_STICK);
        item.mintItem(user2, Item.Type.ARMOUR);
        vm.stopPrank();
        
        assertEq(item.balanceOf(user1), 2);
        assertEq(item.balanceOf(user2), 1);
    }

    function test_MintItem_RevertsIfNotItemCrafting() public {
        vm.prank(user1);
        vm.expectRevert();
        item.mintItem(user1, Item.Type.SABLE);
    }

    function test_MintItem_RevertsIfOwnerTriesToMint() public {
        vm.prank(owner);
        vm.expectRevert();
        item.mintItem(user1, Item.Type.SABLE);
    }

    function test_MarketTransfer_Success() public {
        // First mint an item
        vm.prank(itemCrafting);
        item.mintItem(user1, Item.Type.SABLE);
        
        // Transfer via marketplace
        vm.prank(marketplace);
        item.marketTransfer(user1, user2, 1);
        
        assertEq(item.ownerOf(1), user2);
    }

    function test_MarketTransfer_RevertsIfNotMarketplace() public {
        vm.prank(itemCrafting);
        item.mintItem(user1, Item.Type.SABLE);
        
        vm.prank(user1);
        vm.expectRevert();
        item.marketTransfer(user1, user2, 1);
    }

    function test_MarketTransfer_RevertsIfOwnerTriesToTransfer() public {
        vm.prank(itemCrafting);
        item.mintItem(user1, Item.Type.SABLE);
        
        vm.prank(owner);
        vm.expectRevert();
        item.marketTransfer(user1, user2, 1);
    }

    function test_MarketTransfer_RevertsForNonexistentToken() public {
        vm.prank(marketplace);
        vm.expectRevert();
        item.marketTransfer(user1, user2, 999);
    }

    function test_SetItemCraftingContract_Success() public {
        address newItemCrafting = address(10);
        
        vm.prank(owner);
        item.setItemCraftingContract(newItemCrafting);
        
        // Verify by trying to mint from new address
        vm.prank(newItemCrafting);
        item.mintItem(user1, Item.Type.SABLE);
    }

    function test_SetItemCraftingContract_RevertsIfNotOwner() public {
        vm.prank(user1);
        vm.expectRevert();
        item.setItemCraftingContract(address(10));
    }

    function test_SetItemCraftingContract_OldAddressCannotMint() public {
        address newItemCrafting = address(10);
        
        vm.prank(owner);
        item.setItemCraftingContract(newItemCrafting);
        
        // Old address should fail
        vm.prank(itemCrafting);
        vm.expectRevert();
        item.mintItem(user1, Item.Type.SABLE);
    }

    function test_SetMarketplaceContract_Success() public {
        address newMarketplace = address(11);
        
        vm.prank(owner);
        item.setMarketplaceContract(newMarketplace);
        
        // Setup: mint an item first
        vm.prank(itemCrafting);
        item.mintItem(user1, Item.Type.SABLE);
        
        // Verify by trying to transfer from new address
        vm.prank(newMarketplace);
        item.marketTransfer(user1, user2, 1);
    }

    function test_SetMarketplaceContract_RevertsIfNotOwner() public {
        vm.prank(user1);
        vm.expectRevert();
        item.setMarketplaceContract(address(11));
    }

    function test_SetMarketplaceContract_OldAddressCannotTransfer() public {
        vm.prank(itemCrafting);
        item.mintItem(user1, Item.Type.SABLE);
        
        address newMarketplace = address(11);
        vm.prank(owner);
        item.setMarketplaceContract(newMarketplace);
        
        // Old marketplace should fail
        vm.prank(marketplace);
        vm.expectRevert();
        item.marketTransfer(user1, user2, 1);
    }

    // === Integration Tests ===
    
    function test_FullWorkflow() public {
        // Mint items
        vm.startPrank(itemCrafting);
        item.mintItem(user1, Item.Type.SABLE);
        item.mintItem(user1, Item.Type.ARMOUR);
        vm.stopPrank();
        
        // Transfer via marketplace
        vm.prank(marketplace);
        item.marketTransfer(user1, user2, 1);
        
        // Verify final state
        assertEq(item.balanceOf(user1), 1);
        assertEq(item.balanceOf(user2), 1);
        assertEq(item.ownerOf(1), user2);
        assertEq(item.ownerOf(2), user1);
    }

    // === Fuzz Tests ===
    
    function testFuzz_MintItem_DifferentAddresses(address crafter) public {
        vm.assume(crafter != address(0));
        
        vm.prank(itemCrafting);
        item.mintItem(crafter, Item.Type.SABLE);
        
        assertEq(item.balanceOf(crafter), 1);
    }

    function testFuzz_MarketTransfer_DifferentRecipients(address recipient) public {
        vm.assume(recipient != address(0));
        
        vm.prank(itemCrafting);
        item.mintItem(user1, Item.Type.SABLE);
        
        vm.prank(marketplace);
        item.marketTransfer(user1, recipient, 1);
        
        assertEq(item.ownerOf(1), recipient);
    }
}