// SPDX-License-Identifier: MIT
pragma solidity ~0.8.24;

import "forge-std/Test.sol";
import "../src/ItemCrafting.sol";
import "../src/Item.sol";
import "../src/Resource.sol";

contract ItemCraftingTest is Test {
    ItemCrafting public crafting;
    Item public itemContract;
    Resource public resourceContract;
    
    address public owner = address(1);
    address public user1 = address(2);
    address public user2 = address(3);
    
    function setUp() public {
        vm.startPrank(owner);
        
        // Deploy contracts with owner address
        itemContract = new Item(owner);
        resourceContract = new Resource(owner);
        crafting = new ItemCrafting(address(itemContract), address(resourceContract));
        
        // Set related contracts
        itemContract.setItemCraftingContract(address(crafting));
        resourceContract.setItemCraftingContract(address(crafting));
        resourceContract.setSearchContract(address(owner));
        
        vm.stopPrank();
    }
    
    // Helper function to mint resources for testing
    function mintResourcesForUser(address user, uint256[] memory ids, uint256[] memory amounts) internal {
        vm.prank(owner);
        resourceContract.mintBatch(user, ids, amounts);
    }
    
    // Test: Craft SABLE item
    function testCraftSable() public {
        uint256[] memory resourceIds = new uint256[](3);
        uint256[] memory amounts = new uint256[](3);
        
        resourceIds[0] = uint256(Resource.Type.IRON);
        resourceIds[1] = uint256(Resource.Type.WOOD);
        resourceIds[2] = uint256(Resource.Type.LEATHER);
        
        amounts[0] = 3;
        amounts[1] = 1;
        amounts[2] = 1;
        
        // Mint resources to user1
        mintResourcesForUser(user1, resourceIds, amounts);
        
        // Craft SABLE
        vm.prank(user1);
        crafting.craftItem(Item.Type.SABLE);
        
        // Verify item was minted
        assertEq(itemContract.balanceOf(user1), 1);
        assertEq(uint256(itemContract.getType(1)), uint256(Item.Type.SABLE));
        
        // Verify resources were burned
        assertEq(resourceContract.balanceOf(user1, uint256(Resource.Type.IRON)), 0);
        assertEq(resourceContract.balanceOf(user1, uint256(Resource.Type.WOOD)), 0);
        assertEq(resourceContract.balanceOf(user1, uint256(Resource.Type.LEATHER)), 0);
    }
    
    // Test: Craft ELDERS_STICK item
    function testCraftEldersStick() public {
        uint256[] memory resourceIds = new uint256[](3);
        uint256[] memory amounts = new uint256[](3);
        
        resourceIds[0] = uint256(Resource.Type.WOOD);
        resourceIds[1] = uint256(Resource.Type.GOLD);
        resourceIds[2] = uint256(Resource.Type.DIAMOND);
        
        amounts[0] = 2;
        amounts[1] = 1;
        amounts[2] = 1;
        
        mintResourcesForUser(user1, resourceIds, amounts);
        
        vm.prank(user1);
        crafting.craftItem(Item.Type.ELDERS_STICK);
        
        assertEq(itemContract.balanceOf(user1), 1);
        assertEq(uint256(itemContract.getType(1)), uint256(Item.Type.ELDERS_STICK));
        assertEq(resourceContract.balanceOf(user1, uint256(Resource.Type.WOOD)), 0);
        assertEq(resourceContract.balanceOf(user1, uint256(Resource.Type.GOLD)), 0);
        assertEq(resourceContract.balanceOf(user1, uint256(Resource.Type.DIAMOND)), 0);
    }
    
    // Test: Craft ARMOUR item
    function testCraftArmour() public {
        uint256[] memory resourceIds = new uint256[](3);
        uint256[] memory amounts = new uint256[](3);
        
        resourceIds[0] = uint256(Resource.Type.LEATHER);
        resourceIds[1] = uint256(Resource.Type.IRON);
        resourceIds[2] = uint256(Resource.Type.GOLD);
        
        amounts[0] = 4;
        amounts[1] = 2;
        amounts[2] = 1;
        
        mintResourcesForUser(user1, resourceIds, amounts);
        
        vm.prank(user1);
        crafting.craftItem(Item.Type.ARMOUR);
        
        assertEq(itemContract.balanceOf(user1), 1);
        assertEq(uint256(itemContract.getType(1)), uint256(Item.Type.ARMOUR));
        assertEq(resourceContract.balanceOf(user1, uint256(Resource.Type.LEATHER)), 0);
        assertEq(resourceContract.balanceOf(user1, uint256(Resource.Type.IRON)), 0);
        assertEq(resourceContract.balanceOf(user1, uint256(Resource.Type.GOLD)), 0);
    }
    
    // Test: Craft BRACE item
    function testCraftBrace() public {
        uint256[] memory resourceIds = new uint256[](3);
        uint256[] memory amounts = new uint256[](3);
        
        resourceIds[0] = uint256(Resource.Type.IRON);
        resourceIds[1] = uint256(Resource.Type.GOLD);
        resourceIds[2] = uint256(Resource.Type.DIAMOND);
        
        amounts[0] = 4;
        amounts[1] = 2;
        amounts[2] = 2;
        
        mintResourcesForUser(user1, resourceIds, amounts);
        
        vm.prank(user1);
        crafting.craftItem(Item.Type.BRACE);
        
        assertEq(itemContract.balanceOf(user1), 1);
        assertEq(uint256(itemContract.getType(1)), uint256(Item.Type.BRACE));
        assertEq(resourceContract.balanceOf(user1, uint256(Resource.Type.LEATHER)), 0);
        assertEq(resourceContract.balanceOf(user1, uint256(Resource.Type.IRON)), 0);
        assertEq(resourceContract.balanceOf(user1, uint256(Resource.Type.GOLD)), 0);
    }
    
    // Test: Fail when insufficient resources
    function testCraftWithInsufficientResourcesFails() public {
        uint256[] memory resourceIds = new uint256[](3);
        uint256[] memory amounts = new uint256[](3);
        
        resourceIds[0] = uint256(Resource.Type.IRON);
        resourceIds[1] = uint256(Resource.Type.WOOD);
        resourceIds[2] = uint256(Resource.Type.LEATHER);
        
        // Only give 2 iron instead of required 3
        amounts[0] = 2;
        amounts[1] = 1;
        amounts[2] = 1;
        
        mintResourcesForUser(user1, resourceIds, amounts);
        
        vm.prank(user1);
        vm.expectRevert();
        crafting.craftItem(Item.Type.SABLE);
    }
    
    // Test: Revert when user has no resources
    function testRevertCraftWithNoResources() public {
        vm.prank(user1);
        vm.expectRevert();
        crafting.craftItem(Item.Type.SABLE);
    }
    
    // Test: Multiple crafts by same user
    function testMultipleCrafts() public {
        uint256[] memory resourceIds = new uint256[](3);
        uint256[] memory amounts = new uint256[](3);
        
        resourceIds[0] = uint256(Resource.Type.IRON);
        resourceIds[1] = uint256(Resource.Type.WOOD);
        resourceIds[2] = uint256(Resource.Type.LEATHER);
        
        // Give enough resources for 2 crafts
        amounts[0] = 6;
        amounts[1] = 2;
        amounts[2] = 2;
        
        mintResourcesForUser(user1, resourceIds, amounts);
        
        vm.startPrank(user1);
        crafting.craftItem(Item.Type.SABLE);
        crafting.craftItem(Item.Type.SABLE);
        vm.stopPrank();
        
        assertEq(itemContract.balanceOf(user1), 2);
        assertEq(uint256(itemContract.getType(1)), uint256(Item.Type.SABLE));
        assertEq(uint256(itemContract.getType(2)), uint256(Item.Type.SABLE));

    }
    
    // Test: Different users crafting independently
    function testMultipleUsersCrafting() public {
        uint256[] memory resourceIds = new uint256[](3);
        uint256[] memory amounts = new uint256[](3);
        
        resourceIds[0] = uint256(Resource.Type.IRON);
        resourceIds[1] = uint256(Resource.Type.WOOD);
        resourceIds[2] = uint256(Resource.Type.LEATHER);
        
        amounts[0] = 3;
        amounts[1] = 1;
        amounts[2] = 1;
        
        // Mint resources for both users
        mintResourcesForUser(user1, resourceIds, amounts);
        mintResourcesForUser(user2, resourceIds, amounts);
        
        vm.prank(user1);
        crafting.craftItem(Item.Type.SABLE);
        
        vm.prank(user2);
        crafting.craftItem(Item.Type.SABLE);
        
        assertEq(itemContract.balanceOf(user1), 1);
        assertEq(uint256(itemContract.getType(1)), uint256(Item.Type.SABLE));
        assertEq(itemContract.balanceOf(user2), 1);
        assertEq(uint256(itemContract.getType(1)), uint256(Item.Type.SABLE));
    }
    
    // Test: Craft with excess resources
    function testCraftWithExcessResources() public {
        uint256[] memory resourceIds = new uint256[](3);
        uint256[] memory amounts = new uint256[](3);
        
        resourceIds[0] = uint256(Resource.Type.IRON);
        resourceIds[1] = uint256(Resource.Type.WOOD);
        resourceIds[2] = uint256(Resource.Type.LEATHER);
        
        // Give more resources than needed
        amounts[0] = 10;
        amounts[1] = 5;
        amounts[2] = 5;
        
        mintResourcesForUser(user1, resourceIds, amounts);
        
        vm.prank(user1);
        crafting.craftItem(Item.Type.SABLE);
        
        // Check that only required amounts were burned
        assertEq(resourceContract.balanceOf(user1, uint256(Resource.Type.IRON)), 7);
        assertEq(resourceContract.balanceOf(user1, uint256(Resource.Type.WOOD)), 4);
        assertEq(resourceContract.balanceOf(user1, uint256(Resource.Type.LEATHER)), 4);
    }
    
    function test_revertAttemptToCraftNoneItem() public {
        vm.prank(user1);
        vm.expectRevert();
        crafting.craftItem(Item.Type.NONE);
    }

    // Test: Verify correct resource amounts are burned for each item type
    function testResourceBurningForAllItems() public {
        // Test SABLE: 3 iron, 1 wood, 1 leather
        {
            uint256[] memory ids = new uint256[](3);
            uint256[] memory amounts = new uint256[](3);
            ids[0] = uint256(Resource.Type.IRON);
            ids[1] = uint256(Resource.Type.WOOD);
            ids[2] = uint256(Resource.Type.LEATHER);
            amounts[0] = 10;
            amounts[1] = 10;
            amounts[2] = 10;
            
            address user = address(10000);
            mintResourcesForUser(user, ids, amounts);
            
            vm.prank(user);
            crafting.craftItem(Item.Type.SABLE);
            
            assertEq(resourceContract.balanceOf(user, uint256(Resource.Type.IRON)), 7);
            assertEq(resourceContract.balanceOf(user, uint256(Resource.Type.WOOD)), 9);
            assertEq(resourceContract.balanceOf(user, uint256(Resource.Type.LEATHER)), 9);
        }
        
        // Test ELDERS_STICK: 2 wood, 1 gold, 1 diamond
        {
            uint256[] memory ids = new uint256[](3);
            uint256[] memory amounts = new uint256[](3);
            ids[0] = uint256(Resource.Type.WOOD);
            ids[1] = uint256(Resource.Type.GOLD);
            ids[2] = uint256(Resource.Type.DIAMOND);
            amounts[0] = 10;
            amounts[1] = 10;
            amounts[2] = 10;
            
            address user = address(10001);
            mintResourcesForUser(user, ids, amounts);
            
            vm.prank(user);
            crafting.craftItem(Item.Type.ELDERS_STICK);
            
            assertEq(resourceContract.balanceOf(user, uint256(Resource.Type.WOOD)), 8);
            assertEq(resourceContract.balanceOf(user, uint256(Resource.Type.GOLD)), 9);
            assertEq(resourceContract.balanceOf(user, uint256(Resource.Type.DIAMOND)), 9);
        }

        // Test ARMOUR: 4 leather, 2 iron, 1 gold
        {
            uint256[] memory ids = new uint256[](3);
            uint256[] memory amounts = new uint256[](3);
            ids[0] = uint256(Resource.Type.LEATHER);
            ids[1] = uint256(Resource.Type.IRON);
            ids[2] = uint256(Resource.Type.GOLD);
            amounts[0] = 10;
            amounts[1] = 10;
            amounts[2] = 10;
            
            address user = address(10002);
            mintResourcesForUser(user, ids, amounts);
            
            vm.prank(user);
            crafting.craftItem(Item.Type.ARMOUR);
            
            assertEq(resourceContract.balanceOf(user, uint256(Resource.Type.LEATHER)), 6);
            assertEq(resourceContract.balanceOf(user, uint256(Resource.Type.IRON)), 8);
            assertEq(resourceContract.balanceOf(user, uint256(Resource.Type.GOLD)), 9);
        }

        // Test BRACE: 4 leather, 2 diamon, 2 gold
        {
            uint256[] memory ids = new uint256[](3);
            uint256[] memory amounts = new uint256[](3);
            ids[0] = uint256(Resource.Type.IRON);
            ids[1] = uint256(Resource.Type.GOLD);
            ids[2] = uint256(Resource.Type.DIAMOND);
            amounts[0] = 10;
            amounts[1] = 10;
            amounts[2] = 10;
            
            address user = address(10003);
            mintResourcesForUser(user, ids, amounts);
            
            vm.prank(user);
            crafting.craftItem(Item.Type.BRACE);
            
            assertEq(resourceContract.balanceOf(user, uint256(Resource.Type.IRON)), 6);
            assertEq(resourceContract.balanceOf(user, uint256(Resource.Type.GOLD)), 8);
            assertEq(resourceContract.balanceOf(user, uint256(Resource.Type.DIAMOND)), 8);
        }
    }
}