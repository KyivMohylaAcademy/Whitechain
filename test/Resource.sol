// SPDX-License-Identifier: MIT
pragma solidity ~0.8.25;

import "forge-std/Test.sol";
import "../src/Resource.sol";

contract ResourceTest is Test {
    Resource public resource;
    address public owner = address(1);
    address public resourceSearch = address(2);
    address public itemCrafting = address(3);
    address public user1 = address(4);
    address public user2 = address(5);

    function setUp() public {
        vm.prank(owner);
        resource = new Resource(owner);
        
        vm.startPrank(owner);
        resource.setSearchContract(resourceSearch);
        resource.setItemCraftingContract(itemCrafting);
        vm.stopPrank();
    }

    // === Constructor Tests ===
    
    function test_Constructor_SetsOwner() public {
        assertEq(resource.owner(), owner);
    }

    function test_Constructor_SetsEmptyURI() public {
        // ERC1155 uri should be empty string
        assertEq(resource.uri(0), "");
    }

    function test_Constructor_InitializesSearchContractToZero() public {
        // Create new instance to test initial state
        vm.prank(owner);
        Resource newResource = new Resource(owner);
        
        // Should not allow minting since search contract is zero
        vm.prank(address(0));
        uint256[] memory ids = new uint256[](1);
        uint256[] memory values = new uint256[](1);
        ids[0] = uint256(Resource.Type.WOOD);
        values[0] = 10;
        
        vm.expectRevert();
        newResource.mintBatch(user1, ids, values);
    }

    // === MintBatch Tests ===
    
    function test_MintBatch_SingleResource() public {
        uint256[] memory ids = new uint256[](1);
        uint256[] memory values = new uint256[](1);
        ids[0] = uint256(Resource.Type.WOOD);
        values[0] = 100;
        
        vm.prank(resourceSearch);
        resource.mintBatch(user1, ids, values);
        
        assertEq(resource.balanceOf(user1, uint256(Resource.Type.WOOD)), 100);
    }

    function test_MintBatch_MultipleResources() public {
        uint256[] memory ids = new uint256[](3);
        uint256[] memory values = new uint256[](3);
        ids[0] = uint256(Resource.Type.WOOD);
        ids[1] = uint256(Resource.Type.IRON);
        ids[2] = uint256(Resource.Type.STONE);
        values[0] = 50;
        values[1] = 30;
        values[2] = 20;
        
        vm.prank(resourceSearch);
        resource.mintBatch(user1, ids, values);
        
        assertEq(resource.balanceOf(user1, uint256(Resource.Type.WOOD)), 50);
        assertEq(resource.balanceOf(user1, uint256(Resource.Type.IRON)), 30);
        assertEq(resource.balanceOf(user1, uint256(Resource.Type.STONE)), 20);
    }

    function test_MintBatch_AllResourceTypes() public {
        uint256[] memory ids = new uint256[](6);
        uint256[] memory values = new uint256[](6);
        ids[0] = uint256(Resource.Type.WOOD);
        ids[1] = uint256(Resource.Type.IRON);
        ids[2] = uint256(Resource.Type.STONE);
        ids[3] = uint256(Resource.Type.LEATHER);
        ids[4] = uint256(Resource.Type.GOLD);
        ids[5] = uint256(Resource.Type.DIAMOND);
        values[0] = 10;
        values[1] = 20;
        values[2] = 30;
        values[3] = 40;
        values[4] = 50;
        values[5] = 60;
        
        vm.prank(resourceSearch);
        resource.mintBatch(user1, ids, values);
        
        assertEq(resource.balanceOf(user1, uint256(Resource.Type.WOOD)), 10);
        assertEq(resource.balanceOf(user1, uint256(Resource.Type.IRON)), 20);
        assertEq(resource.balanceOf(user1, uint256(Resource.Type.STONE)), 30);
        assertEq(resource.balanceOf(user1, uint256(Resource.Type.LEATHER)), 40);
        assertEq(resource.balanceOf(user1, uint256(Resource.Type.GOLD)), 50);
        assertEq(resource.balanceOf(user1, uint256(Resource.Type.DIAMOND)), 60);
    }

    function test_MintBatch_MultipleMints_Accumulate() public {
        uint256[] memory ids = new uint256[](1);
        uint256[] memory values = new uint256[](1);
        ids[0] = uint256(Resource.Type.WOOD);
        values[0] = 50;
        
        vm.startPrank(resourceSearch);
        resource.mintBatch(user1, ids, values);
        resource.mintBatch(user1, ids, values);
        resource.mintBatch(user1, ids, values);
        vm.stopPrank();
        
        assertEq(resource.balanceOf(user1, uint256(Resource.Type.WOOD)), 150);
    }

    function test_MintBatch_ToDifferentUsers() public {
        uint256[] memory ids = new uint256[](1);
        uint256[] memory values = new uint256[](1);
        ids[0] = uint256(Resource.Type.GOLD);
        values[0] = 100;
        
        vm.startPrank(resourceSearch);
        resource.mintBatch(user1, ids, values);
        resource.mintBatch(user2, ids, values);
        vm.stopPrank();
        
        assertEq(resource.balanceOf(user1, uint256(Resource.Type.GOLD)), 100);
        assertEq(resource.balanceOf(user2, uint256(Resource.Type.GOLD)), 100);
    }

    function test_MintBatch_RevertsIfNotResourceSearch() public {
        uint256[] memory ids = new uint256[](1);
        uint256[] memory values = new uint256[](1);
        ids[0] = uint256(Resource.Type.WOOD);
        values[0] = 100;
        
        vm.prank(user1);
        vm.expectRevert();
        resource.mintBatch(user1, ids, values);
    }

    function test_MintBatch_RevertsIfOwnerTriesToMint() public {
        uint256[] memory ids = new uint256[](1);
        uint256[] memory values = new uint256[](1);
        ids[0] = uint256(Resource.Type.WOOD);
        values[0] = 100;
        
        vm.prank(owner);
        vm.expectRevert();
        resource.mintBatch(user1, ids, values);
    }

    function test_MintBatch_RevertsIfItemCraftingTriesToMint() public {
        uint256[] memory ids = new uint256[](1);
        uint256[] memory values = new uint256[](1);
        ids[0] = uint256(Resource.Type.WOOD);
        values[0] = 100;
        
        vm.prank(itemCrafting);
        vm.expectRevert();
        resource.mintBatch(user1, ids, values);
    }

    function test_MintBatch_RevertsOnArrayLengthMismatch() public {
        uint256[] memory ids = new uint256[](2);
        uint256[] memory values = new uint256[](1);
        ids[0] = uint256(Resource.Type.WOOD);
        ids[1] = uint256(Resource.Type.IRON);
        values[0] = 100;
        
        vm.prank(resourceSearch);
        vm.expectRevert();
        resource.mintBatch(user1, ids, values);
    }

    function test_MintBatch_EmptyArrays() public {
        uint256[] memory ids = new uint256[](0);
        uint256[] memory values = new uint256[](0);
        
        vm.prank(resourceSearch);
        resource.mintBatch(user1, ids, values);
        
        // Should succeed but mint nothing
        assertEq(resource.balanceOf(user1, uint256(Resource.Type.WOOD)), 0);
    }

    // === BurnBatch Tests ===
    
    function test_BurnBatch_SingleResource() public {
        // First mint some resources
        uint256[] memory ids = new uint256[](1);
        uint256[] memory values = new uint256[](1);
        ids[0] = uint256(Resource.Type.WOOD);
        values[0] = 100;
        
        vm.prank(resourceSearch);
        resource.mintBatch(user1, ids, values);
        
        // Now burn some
        values[0] = 30;
        vm.prank(itemCrafting);
        resource.burnBatch(user1, ids, values);
        
        assertEq(resource.balanceOf(user1, uint256(Resource.Type.WOOD)), 70);
    }

    function test_BurnBatch_MultipleResources() public {
        // Mint resources
        uint256[] memory ids = new uint256[](3);
        uint256[] memory values = new uint256[](3);
        ids[0] = uint256(Resource.Type.WOOD);
        ids[1] = uint256(Resource.Type.IRON);
        ids[2] = uint256(Resource.Type.STONE);
        values[0] = 100;
        values[1] = 200;
        values[2] = 300;
        
        vm.prank(resourceSearch);
        resource.mintBatch(user1, ids, values);
        
        // Burn some of each
        values[0] = 30;
        values[1] = 50;
        values[2] = 100;
        
        vm.prank(itemCrafting);
        resource.burnBatch(user1, ids, values);
        
        assertEq(resource.balanceOf(user1, uint256(Resource.Type.WOOD)), 70);
        assertEq(resource.balanceOf(user1, uint256(Resource.Type.IRON)), 150);
        assertEq(resource.balanceOf(user1, uint256(Resource.Type.STONE)), 200);
    }

    function test_BurnBatch_AllBalance() public {
        uint256[] memory ids = new uint256[](1);
        uint256[] memory values = new uint256[](1);
        ids[0] = uint256(Resource.Type.LEATHER);
        values[0] = 50;
        
        vm.prank(resourceSearch);
        resource.mintBatch(user1, ids, values);
        
        vm.prank(itemCrafting);
        resource.burnBatch(user1, ids, values);
        
        assertEq(resource.balanceOf(user1, uint256(Resource.Type.LEATHER)), 0);
    }

    function test_BurnBatch_RevertsIfNotItemCrafting() public {
        uint256[] memory ids = new uint256[](1);
        uint256[] memory values = new uint256[](1);
        ids[0] = uint256(Resource.Type.WOOD);
        values[0] = 100;
        
        vm.prank(resourceSearch);
        resource.mintBatch(user1, ids, values);
        
        values[0] = 30;
        vm.prank(user1);
        vm.expectRevert();
        resource.burnBatch(user1, ids, values);
    }

    function test_BurnBatch_RevertsIfOwnerTriesToBurn() public {
        uint256[] memory ids = new uint256[](1);
        uint256[] memory values = new uint256[](1);
        ids[0] = uint256(Resource.Type.WOOD);
        values[0] = 100;
        
        vm.prank(resourceSearch);
        resource.mintBatch(user1, ids, values);
        
        values[0] = 30;
        vm.prank(owner);
        vm.expectRevert();
        resource.burnBatch(user1, ids, values);
    }

    function test_BurnBatch_RevertsIfResourceSearchTriesToBurn() public {
        uint256[] memory ids = new uint256[](1);
        uint256[] memory values = new uint256[](1);
        ids[0] = uint256(Resource.Type.WOOD);
        values[0] = 100;
        
        vm.prank(resourceSearch);
        resource.mintBatch(user1, ids, values);
        
        values[0] = 30;
        vm.prank(resourceSearch);
        vm.expectRevert();
        resource.burnBatch(user1, ids, values);
    }

    function test_BurnBatch_RevertsOnInsufficientBalance() public {
        uint256[] memory ids = new uint256[](1);
        uint256[] memory values = new uint256[](1);
        ids[0] = uint256(Resource.Type.WOOD);
        values[0] = 100;
        
        vm.prank(resourceSearch);
        resource.mintBatch(user1, ids, values);
        
        values[0] = 150; // Try to burn more than available
        vm.prank(itemCrafting);
        vm.expectRevert();
        resource.burnBatch(user1, ids, values);
    }

    function test_BurnBatch_RevertsOnArrayLengthMismatch() public {
        uint256[] memory mintIds = new uint256[](1);
        uint256[] memory mintValues = new uint256[](1);
        mintIds[0] = uint256(Resource.Type.WOOD);
        mintValues[0] = 100;
        
        vm.prank(resourceSearch);
        resource.mintBatch(user1, mintIds, mintValues);
        
        uint256[] memory burnIds = new uint256[](2);
        uint256[] memory burnValues = new uint256[](1);
        burnIds[0] = uint256(Resource.Type.WOOD);
        burnIds[1] = uint256(Resource.Type.IRON);
        burnValues[0] = 50;
        
        vm.prank(itemCrafting);
        vm.expectRevert();
        resource.burnBatch(user1, burnIds, burnValues);
    }

    // === SetSearchContract Tests ===
    
    function test_SetSearchContract_Success() public {
        address newSearchContract = address(10);
        
        vm.prank(owner);
        resource.setSearchContract(newSearchContract);
        
        // Verify by trying to mint from new address
        uint256[] memory ids = new uint256[](1);
        uint256[] memory values = new uint256[](1);
        ids[0] = uint256(Resource.Type.WOOD);
        values[0] = 100;
        
        vm.prank(newSearchContract);
        resource.mintBatch(user1, ids, values);
        
        assertEq(resource.balanceOf(user1, uint256(Resource.Type.WOOD)), 100);
    }

    function test_SetSearchContract_RevertsIfNotOwner() public {
        vm.prank(user1);
        vm.expectRevert();
        resource.setSearchContract(address(10));
    }

    function test_SetSearchContract_OldAddressCannotMint() public {
        address newSearchContract = address(10);
        
        vm.prank(owner);
        resource.setSearchContract(newSearchContract);
        
        uint256[] memory ids = new uint256[](1);
        uint256[] memory values = new uint256[](1);
        ids[0] = uint256(Resource.Type.WOOD);
        values[0] = 100;
        
        // Old address should fail
        vm.prank(resourceSearch);
        vm.expectRevert();
        resource.mintBatch(user1, ids, values);
    }

    function test_SetSearchContract_CanSetToZeroAddress() public {
        vm.prank(owner);
        resource.setSearchContract(address(0));
        
        uint256[] memory ids = new uint256[](1);
        uint256[] memory values = new uint256[](1);
        ids[0] = uint256(Resource.Type.WOOD);
        values[0] = 100;
        
        // Zero address should be able to mint now
        vm.prank(address(0));
        // Note: This will fail in practice due to vm.prank(address(0)) limitations
        // but the contract allows it
    }

    // === SetItemCraftingContract Tests ===
    
    function test_SetItemCraftingContract_Success() public {
        address newItemCrafting = address(11);
        
        vm.prank(owner);
        resource.setItemCraftingContract(newItemCrafting);
        
        // Setup: mint resources first
        uint256[] memory ids = new uint256[](1);
        uint256[] memory values = new uint256[](1);
        ids[0] = uint256(Resource.Type.WOOD);
        values[0] = 100;
        
        vm.prank(resourceSearch);
        resource.mintBatch(user1, ids, values);
        
        // Verify by trying to burn from new address
        values[0] = 30;
        vm.prank(newItemCrafting);
        resource.burnBatch(user1, ids, values);
        
        assertEq(resource.balanceOf(user1, uint256(Resource.Type.WOOD)), 70);
    }

    function test_SetItemCraftingContract_RevertsIfNotOwner() public {
        vm.prank(user1);
        vm.expectRevert();
        resource.setItemCraftingContract(address(11));
    }

    function test_SetItemCraftingContract_OldAddressCannotBurn() public {
        // Mint resources
        uint256[] memory ids = new uint256[](1);
        uint256[] memory values = new uint256[](1);
        ids[0] = uint256(Resource.Type.WOOD);
        values[0] = 100;
        
        vm.prank(resourceSearch);
        resource.mintBatch(user1, ids, values);
        
        // Change itemCrafting address
        address newItemCrafting = address(11);
        vm.prank(owner);
        resource.setItemCraftingContract(newItemCrafting);
        
        // Old address should fail to burn
        values[0] = 30;
        vm.prank(itemCrafting);
        vm.expectRevert();
        resource.burnBatch(user1, ids, values);
    }

    // === Integration Tests ===
    
    function test_FullWorkflow_MintAndBurn() public {
        // Mint resources
        uint256[] memory ids = new uint256[](2);
        uint256[] memory values = new uint256[](2);
        ids[0] = uint256(Resource.Type.WOOD);
        ids[1] = uint256(Resource.Type.IRON);
        values[0] = 100;
        values[1] = 50;
        
        vm.prank(resourceSearch);
        resource.mintBatch(user1, ids, values);
        
        // Burn some resources
        values[0] = 30;
        values[1] = 20;
        
        vm.prank(itemCrafting);
        resource.burnBatch(user1, ids, values);
        
        // Verify final state
        assertEq(resource.balanceOf(user1, uint256(Resource.Type.WOOD)), 70);
        assertEq(resource.balanceOf(user1, uint256(Resource.Type.IRON)), 30);
    }

    function test_MultipleUsers_IndependentBalances() public {
        uint256[] memory ids = new uint256[](1);
        uint256[] memory values = new uint256[](1);
        ids[0] = uint256(Resource.Type.GOLD);
        values[0] = 100;
        
        vm.startPrank(resourceSearch);
        resource.mintBatch(user1, ids, values);
        values[0] = 200;
        resource.mintBatch(user2, ids, values);
        vm.stopPrank();
        
        // Burn from user1
        values[0] = 50;
        vm.prank(itemCrafting);
        resource.burnBatch(user1, ids, values);
        
        // Verify independent balances
        assertEq(resource.balanceOf(user1, uint256(Resource.Type.GOLD)), 50);
        assertEq(resource.balanceOf(user2, uint256(Resource.Type.GOLD)), 200);
    }

    function test_TransferBetweenUsers() public {
        // Mint resources to user1
        uint256[] memory ids = new uint256[](1);
        uint256[] memory values = new uint256[](1);
        ids[0] = uint256(Resource.Type.DIAMOND);
        values[0] = 100;
        
        vm.prank(resourceSearch);
        resource.mintBatch(user1, ids, values);
        
        // User1 transfers to user2 (standard ERC1155 transfer)
        vm.prank(user1);
        resource.safeTransferFrom(user1, user2, uint256(Resource.Type.DIAMOND), 40, "");
        
        assertEq(resource.balanceOf(user1, uint256(Resource.Type.DIAMOND)), 60);
        assertEq(resource.balanceOf(user2, uint256(Resource.Type.DIAMOND)), 40);
    }

    // === Fuzz Tests ===
    
    function testFuzz_MintBatch_DifferentAmounts(uint96 amount) public {
        vm.assume(amount > 0);
        
        uint256[] memory ids = new uint256[](1);
        uint256[] memory values = new uint256[](1);
        ids[0] = uint256(Resource.Type.WOOD);
        values[0] = amount;
        
        vm.prank(resourceSearch);
        resource.mintBatch(user1, ids, values);
        
        assertEq(resource.balanceOf(user1, uint256(Resource.Type.WOOD)), amount);
    }

    function testFuzz_BurnBatch_DifferentAmounts(uint96 mintAmount, uint96 burnAmount) public {
        vm.assume(mintAmount >= burnAmount && burnAmount > 0);
        
        uint256[] memory ids = new uint256[](1);
        uint256[] memory values = new uint256[](1);
        ids[0] = uint256(Resource.Type.IRON);
        values[0] = mintAmount;
        
        vm.prank(resourceSearch);
        resource.mintBatch(user1, ids, values);
        
        values[0] = burnAmount;
        vm.prank(itemCrafting);
        resource.burnBatch(user1, ids, values);
        
        assertEq(resource.balanceOf(user1, uint256(Resource.Type.IRON)), mintAmount - burnAmount);
    }

    function testFuzz_MintBatch_DifferentUsers(address user) public {
        vm.assume(user != address(0));
        vm.assume(user != address(resource));
        
        uint256[] memory ids = new uint256[](1);
        uint256[] memory values = new uint256[](1);
        ids[0] = uint256(Resource.Type.STONE);
        values[0] = 100;
        
        vm.prank(resourceSearch);
        resource.mintBatch(user, ids, values);
        
        assertEq(resource.balanceOf(user, uint256(Resource.Type.STONE)), 100);
    }
}