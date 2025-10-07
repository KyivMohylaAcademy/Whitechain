// SPDX-License-Identifier: MIT
pragma solidity ~0.8.24;

import "forge-std/Test.sol";
import "../src/Marketplace.sol";
import "../src/MagicCoins.sol";
import "../src/Item.sol";
import "../src/ItemCrafting.sol";

contract MarketplaceTest is Test {
    Marketplace public marketplace;
    MagicCoins public magicCoins;
    Item public item;
    
    address public owner;
    address public seller;
    address public buyer;
    address public user1;
    address public user2;
    address public itemCrafting;

    function setUp() public {
        owner = address(1);
        seller = address(2);
        buyer = address(3);
        user1 = address(4);
        user2 = address(5);
        itemCrafting = address(6);  

        // Deploy MagicCoins
        vm.prank(owner);
        magicCoins = new MagicCoins(owner);

        // Deploy Item
        item = new Item(owner);
        // Deploy Marketplace
        marketplace = new Marketplace(address(magicCoins), address(item));
        // Set marketplace as market contract for Item
        vm.prank(owner);
        item.setMarketplaceContract(address(marketplace));
        vm.prank(owner);
        item.setItemCraftingContract(itemCrafting);
        vm.prank(owner);
        magicCoins.setMarketContract(address(marketplace));
    }

    // ========== putItemToSell Tests ==========

    function test_PutItemToSell_AsOwner() public {
        // Mint an item to seller
        vm.prank(itemCrafting);
        item.mintItem(seller, Item.Type.SABLE);

        // Put item for sale
        vm.prank(seller);
        marketplace.putItemToSell(1, 100 ether);
    }

    function test_PutItemToSell_AsApproved() public {
        // Mint an item to seller
        vm.prank(itemCrafting);
        item.mintItem(seller, Item.Type.SABLE);

        // Approve user1 for the item
        vm.prank(seller);
        item.approve(user1, 1);

        // user1 can put item for sale
        vm.prank(user1);
        marketplace.putItemToSell(1, 100 ether);
    }

    function test_RevertWhen_PutItemToSell_ZeroPrice() public {
        vm.prank(itemCrafting);
        item.mintItem(seller, Item.Type.SABLE);

        vm.prank(seller);
        vm.expectRevert();
        marketplace.putItemToSell(1, 0);
    }

    function test_RevertWhen_PutItemToSell_NotOwnerOrApproved() public {
        vm.prank(itemCrafting);
        item.mintItem(seller, Item.Type.SABLE);

        // Note: There's a bug in the contract - it checks _magicCoinsContract instead of _itemContract
        // This test will fail with the current buggy contract
        vm.prank(buyer);
        vm.expectRevert();
        marketplace.putItemToSell(1, 100 ether);
    }

    function test_PutItemToSell_UpdatePrice() public {
        vm.prank(itemCrafting);
        item.mintItem(seller, Item.Type.SABLE);

        vm.prank(seller);
        marketplace.putItemToSell(1, 100 ether);

        // Update price
        vm.prank(seller);
        marketplace.putItemToSell(1, 200 ether);

        // Price should be updated (verified through buyItem behavior)
    }

    function testFuzz_PutItemToSell(uint256 price) public {
        vm.assume(price > 0);
        vm.assume(price < type(uint256).max / 2);

        vm.prank(itemCrafting);
        item.mintItem(seller, Item.Type.SABLE);

        vm.prank(seller);
        marketplace.putItemToSell(1, price);
    }

    // ========== removeItemFromSell Tests ==========

    function test_RemoveItemFromSell_AsOwner() public {
        vm.prank(itemCrafting);
        item.mintItem(seller, Item.Type.SABLE);

        vm.prank(seller);
        marketplace.putItemToSell(1, 100 ether);

        vm.prank(seller);
        marketplace.removeItemFromSell(1);

        // Verify item is removed by trying to buy (should fail)
        vm.prank(buyer);
        vm.expectRevert();
        marketplace.buyItem(1);
    }

    function test_RemoveItemFromSell_AsApproved() public {
        vm.prank(itemCrafting);
        item.mintItem(seller, Item.Type.SABLE);

        vm.prank(seller);
        item.approve(user1, 1);

        vm.prank(seller);
        marketplace.putItemToSell(1, 100 ether);

        vm.prank(user1);
        marketplace.removeItemFromSell(1);
    }

    function test_RevertWhen_RemoveItemFromSell_NotOwnerOrApproved() public {
        vm.prank(itemCrafting);
        item.mintItem(seller, Item.Type.SABLE);

        vm.prank(seller);
        marketplace.putItemToSell(1, 100 ether);

        vm.prank(buyer);
        vm.expectRevert();
        marketplace.removeItemFromSell(1);
    }

    function test_RemoveItemFromSell_ItemNotForSale() public {
        vm.prank(itemCrafting);
        item.mintItem(seller, Item.Type.SABLE);

        // Should not revert even if item was never for sale
        vm.prank(seller);
        marketplace.removeItemFromSell(1);
    }

    // ========== buyItem Tests ==========

    function test_BuyItem() public {
        uint256 price = 100;

        // Setup: mint item to seller
        vm.prank(itemCrafting);
        item.mintItem(seller, Item.Type.SABLE);

        // Put item for sale
        vm.prank(seller);
        marketplace.putItemToSell(1, price);

        // Give buyer magic coins
        vm.prank(address(marketplace));
        magicCoins.mint(buyer, price);

        // Buy item
        vm.prank(buyer);
        marketplace.buyItem(1);

        // Verify ownership transferred
        assertEq(item.ownerOf(1), buyer);
        
        // Verify buyer's coins burned
        assertEq(magicCoins.balanceOf(buyer), 0);
        
        // Verify seller received coins
        assertEq(magicCoins.balanceOf(seller), price);
    }

    function test_RevertWhen_BuyItem_NotForSale() public {
        vm.prank(itemCrafting);
        item.mintItem(seller, Item.Type.SABLE);

        vm.prank(buyer);
        vm.expectRevert();
        marketplace.buyItem(1);
    }

    function test_RevertWhen_BuyItem_InsufficientFunds() public {
        uint256 price = 100 ether;

        vm.prank(itemCrafting);
        item.mintItem(seller, Item.Type.SABLE);

        vm.prank(seller);
        marketplace.putItemToSell(1, price);

        // Give buyer insufficient coins
        vm.prank(address(marketplace));
        magicCoins.mint(buyer, price - 1);

        vm.prank(buyer);
        vm.expectRevert();
        marketplace.buyItem(1);
    }

    function test_BuyItem_MultipleItems() public {
        uint256 price1 = 100;
        uint256 price2 = 200;

        // Mint items
        vm.prank(itemCrafting);
        item.mintItem(seller, Item.Type.SABLE);
        
        vm.prank(itemCrafting);
        item.mintItem(seller, Item.Type.ELDERS_STICK);

        // Put items for sale
        vm.prank(seller);
        marketplace.putItemToSell(1, price1);
        
        vm.prank(seller);
        marketplace.putItemToSell(2, price2);

        // Give buyer enough coins
        vm.prank(address(marketplace));
        magicCoins.mint(buyer, price1 + price2);

        // Buy first item
        vm.prank(buyer);
        marketplace.buyItem(1);

        assertEq(item.ownerOf(1), buyer);
        assertEq(magicCoins.balanceOf(buyer), price2);
        assertEq(magicCoins.balanceOf(seller), price1);

        // Buy second item
        vm.prank(buyer);
        marketplace.buyItem(2);

        assertEq(item.ownerOf(2), buyer);
        assertEq(magicCoins.balanceOf(buyer), 0);
        assertEq(magicCoins.balanceOf(seller), price1 + price2);
    }

    function testFuzz_BuyItem(uint256 price) public {
        price = bound(price, 1, type(uint256).max / 2);

        vm.prank(itemCrafting);
        item.mintItem(seller, Item.Type.SABLE);

        vm.prank(seller);
        marketplace.putItemToSell(1, price);

        vm.prank(address(marketplace));
        magicCoins.mint(buyer, price);

        vm.prank(buyer);
        marketplace.buyItem(1);

        assertEq(item.ownerOf(1), buyer);
        assertEq(magicCoins.balanceOf(buyer), 0);
        assertEq(magicCoins.balanceOf(seller), price);
    }

    // ========== Integration Tests ==========

    function test_FullMarketplaceFlow() public {
        uint256 itemId = 1;
        uint256 price = 50 ether;

        // Step 1: Mint item to seller
        vm.prank(itemCrafting);
        item.mintItem(seller, Item.Type.SABLE);
        assertEq(item.ownerOf(itemId), seller);

        // Step 2: Seller puts item for sale
        vm.prank(seller);
        marketplace.putItemToSell(itemId, price);

        // Step 3: Give buyer coins
        vm.prank(address(marketplace));
        magicCoins.mint(buyer, price);
        assertEq(magicCoins.balanceOf(buyer), price);

        // Step 4: Buyer purchases item
        vm.prank(buyer);
        marketplace.buyItem(itemId);

        // Verify final state
        assertEq(item.ownerOf(itemId), buyer);
        assertEq(magicCoins.balanceOf(buyer), 0);
        assertEq(magicCoins.balanceOf(seller), price);
    }

    function test_SellerCancelsBeforeSale() public {
        vm.prank(itemCrafting);
        item.mintItem(seller, Item.Type.SABLE);

        vm.prank(seller);
        marketplace.putItemToSell(1, 100 ether);

        // Seller changes mind
        vm.prank(seller);
        marketplace.removeItemFromSell(1);

        // Buyer cannot buy
        vm.prank(address(marketplace));
        magicCoins.mint(buyer, 100 ether);

        vm.prank(buyer);
        vm.expectRevert();
        marketplace.buyItem(1);

        // Seller still owns item
        assertEq(item.ownerOf(1), seller);
    }

    function test_MultipleSellersBuyers() public {
        address seller2 = address(6);
        address buyer2 = address(7);

        // Seller 1 lists item 1
        vm.prank(itemCrafting);
        item.mintItem(seller, Item.Type.SABLE);
        vm.prank(seller);
        marketplace.putItemToSell(1, 100 ether);

        // Seller 2 lists item 2
        vm.prank(itemCrafting);
        item.mintItem(seller2, Item.Type.ELDERS_STICK);
        vm.prank(seller2);
        marketplace.putItemToSell(2, 200 ether);

        // Give buyers coins
        vm.prank(address(marketplace));
        magicCoins.mint(buyer, 100 ether);
        vm.prank(address(marketplace));
        magicCoins.mint(buyer2, 200 ether);

        // Buyer 1 buys item 1
        vm.prank(buyer);
        marketplace.buyItem(1);

        // Buyer 2 buys item 2
        vm.prank(buyer2);
        marketplace.buyItem(2);

        assertEq(item.ownerOf(1), buyer);
        assertEq(item.ownerOf(2), buyer2);
        assertEq(magicCoins.balanceOf(seller), 100 ether);
        assertEq(magicCoins.balanceOf(seller2), 200 ether);
    }

    function test_ResellItem() public {
        uint256 firstPrice = 100 ether;
        uint256 secondPrice = 150 ether;

        // Initial sale
        vm.prank(itemCrafting);
        item.mintItem(seller, Item.Type.SABLE);
        
        vm.prank(seller);
        marketplace.putItemToSell(1, firstPrice);

        vm.prank(address(marketplace));
        magicCoins.mint(buyer, firstPrice);

        vm.prank(buyer);
        marketplace.buyItem(1);

        assertEq(item.ownerOf(1), buyer);

        // Buyer becomes seller and resells
        vm.prank(buyer);
        marketplace.putItemToSell(1, secondPrice);

        vm.prank(address(marketplace));
        magicCoins.mint(user1, secondPrice);

        vm.prank(user1);
        marketplace.buyItem(1);

        assertEq(item.ownerOf(1), user1);
        assertEq(magicCoins.balanceOf(buyer), secondPrice);
    }

    function test_PriceUpdate() public {
        vm.prank(itemCrafting);
        item.mintItem(seller, Item.Type.SABLE);

        // Initial price
        vm.prank(seller);
        marketplace.putItemToSell(1, 100 ether);

        // Update to higher price
        vm.prank(seller);
        marketplace.putItemToSell(1, 200 ether);

        // Buyer needs 200 ether, not 100
        vm.prank(address(marketplace));
        magicCoins.mint(buyer, 100 ether);

        vm.prank(buyer);
        vm.expectRevert();
        marketplace.buyItem(1);

        // Give correct amount
        vm.prank(address(marketplace));
        magicCoins.mint(buyer, 100 ether); // Total 200 now

        vm.prank(buyer);
        marketplace.buyItem(1);

        assertEq(magicCoins.balanceOf(seller), 200 ether);
    }

    // ========== Edge Cases ==========

    function test_BuyOwnItem() public {
        uint256 price = 100 ether;

        vm.prank(itemCrafting);
        item.mintItem(seller, Item.Type.SABLE);

        vm.prank(seller);
        marketplace.putItemToSell(1, price);

        // Give seller coins to buy their own item
        vm.prank(address(marketplace));
        magicCoins.mint(seller, price);

        // Seller buys their own item (allowed in current implementation)
        vm.prank(seller);
        marketplace.buyItem(1);

        // Seller still owns item
        assertEq(item.ownerOf(1), seller);
        // Coins were burned and reminted (net zero change)
        assertEq(magicCoins.balanceOf(seller), price);
    }

    function test_RevertWhen_BuyItem_AfterRemoved() public {
        vm.prank(itemCrafting);
        item.mintItem(seller, Item.Type.SABLE);

        vm.prank(seller);
        marketplace.putItemToSell(1, 100 ether);

        vm.prank(seller);
        marketplace.removeItemFromSell(1);

        vm.prank(address(marketplace));
        magicCoins.mint(buyer, 100 ether);

        vm.prank(buyer);
        vm.expectRevert();
        marketplace.buyItem(1);
    }
}