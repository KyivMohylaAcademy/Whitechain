// SPDX-License-Identifier: MIT
pragma solidity ~0.8.24;

import "forge-std/Test.sol";
import "../src/MagicCoins.sol";

contract MagicCoinsTest is Test {
    MagicCoins public token;
    address public owner;
    address public marketContract;
    address public user1;
    address public user2;

    event Transfer(address indexed from, address indexed to, uint256 value);

    function setUp() public {
        owner = address(1);
        user1 = address(2);
        user2 = address(3);
        marketContract = address(42);

        vm.prank(owner);
        token = new MagicCoins(owner);
    }

    // ========== Constructor Tests ==========

    function test_Constructor() public view {
        assertEq(token.name(), "MagicCoins");
        assertEq(token.symbol(), "MGC");
        assertEq(token.owner(), owner);
        assertEq(token.totalSupply(), 0);
    }


    function test_RevertWhen_SetMarketContractCalledByNonOwner() public {
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", user1));
        token.setMarketContract(marketContract);
    }

    function test_SetMarketContractToZeroAddress() public {
        vm.prank(owner);
        token.setMarketContract(address(0));
        // Should succeed - contract allows setting to zero address
    }

    // ========== Mint Tests ==========

    function test_Mint() public {
        // Set up market contract
        vm.prank(owner);
        token.setMarketContract(marketContract);

        // Mint tokens
        vm.prank(marketContract);
        vm.expectEmit(true, true, false, true);
        emit Transfer(address(0), user1, 1000 ether);
        token.mint(user1, 1000 ether);

        assertEq(token.balanceOf(user1), 1000 ether);
        assertEq(token.totalSupply(), 1000 ether);
    }

    function test_RevertWhen_MintCalledByNonMarketContract() public {
        vm.prank(owner);
        token.setMarketContract(marketContract);

        vm.prank(user1);
        vm.expectRevert();
        token.mint(user1, 1000 ether);
    }

    function test_RevertWhen_MintCalledBeforeMarketContractSet() public {
        vm.prank(marketContract);
        vm.expectRevert();
        token.mint(user1, 1000 ether);
    }

    function test_RevertWhen_MintCalledByOwner() public {
        vm.prank(owner);
        token.setMarketContract(marketContract);

        vm.prank(owner);
        vm.expectRevert();
        token.mint(user1, 1000 ether);
    }

    function testFuzz_Mint(address to, uint256 amount) public {
        vm.assume(to != address(0));
        vm.assume(amount < type(uint256).max / 2); // Avoid overflow

        vm.prank(owner);
        token.setMarketContract(marketContract);

        vm.prank(marketContract);
        token.mint(to, amount);

        assertEq(token.balanceOf(to), amount);
        assertEq(token.totalSupply(), amount);
    }

    // ========== Burn Tests ==========

    function test_Burn() public {
        // Setup: mint tokens first
        vm.prank(owner);
        token.setMarketContract(marketContract);

        vm.prank(marketContract);
        token.mint(user1, 1000 ether);

        // Burn tokens
        vm.prank(marketContract);
        vm.expectEmit(true, true, false, true);
        emit Transfer(user1, address(0), 500 ether);
        token.burn(user1, 500 ether);

        assertEq(token.balanceOf(user1), 500 ether);
        assertEq(token.totalSupply(), 500 ether);
    }

    function test_RevertWhen_BurnCalledByNonMarketContract() public {
        vm.prank(owner);
        token.setMarketContract(marketContract);

        vm.prank(marketContract);
        token.mint(user1, 1000 ether);

        vm.prank(user1);
        vm.expectRevert();
        token.burn(user1, 500 ether);
    }

    function test_RevertWhen_BurnCalledBeforeMarketContractSet() public {
        vm.prank(marketContract);
        vm.expectRevert();
        token.burn(user1, 500 ether);
    }

    function test_RevertWhen_BurnExceedsBalance() public {
        vm.prank(owner);
        token.setMarketContract(marketContract);

        vm.prank(marketContract);
        token.mint(user1, 1000 ether);

        vm.prank(marketContract);
        vm.expectRevert();
        token.burn(user1, 1001 ether);
    }

    function testFuzz_Burn(uint256 mintAmount, uint256 burnAmount) public {
        mintAmount = bound(mintAmount, 1, type(uint256).max / 2);
        burnAmount = bound(burnAmount, 0, mintAmount);

        vm.prank(owner);
        token.setMarketContract(marketContract);

        vm.prank(marketContract);
        token.mint(user1, mintAmount);

        vm.prank(marketContract);
        token.burn(user1, burnAmount);

        assertEq(token.balanceOf(user1), mintAmount - burnAmount);
        assertEq(token.totalSupply(), mintAmount - burnAmount);
    }

    // ========== Multiple Operations Tests ==========

    function test_MultipleMintAndBurn() public {
        vm.prank(owner);
        token.setMarketContract(marketContract);

        // Mint to user1
        vm.prank(marketContract);
        token.mint(user1, 1000 ether);

        // Mint to user2
        vm.prank(marketContract);
        token.mint(user2, 2000 ether);

        assertEq(token.totalSupply(), 3000 ether);

        // Burn from user1
        vm.prank(marketContract);
        token.burn(user1, 500 ether);

        assertEq(token.balanceOf(user1), 500 ether);
        assertEq(token.balanceOf(user2), 2000 ether);
        assertEq(token.totalSupply(), 2500 ether);
    }

    // ========== Ownership Tests ==========

    function test_TransferOwnership() public {
        vm.prank(owner);
        token.transferOwnership(user1);

        assertEq(token.owner(), user1);
    }

    function test_RevertWhen_NonOwnerTransfersOwnership() public {
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", user1));
        token.transferOwnership(user2);
    }

    // ========== Market Contract Change Tests ==========

    function test_ChangeMarketContract() public {
        address newMarket = makeAddr("newMarket");

        // Set initial market contract
        vm.prank(owner);
        token.setMarketContract(marketContract);

        // Mint with initial market
        vm.prank(marketContract);
        token.mint(user1, 1000 ether);

        // Change market contract
        vm.prank(owner);
        token.setMarketContract(newMarket);

        // Old market should no longer work
        vm.prank(marketContract);
        vm.expectRevert();
        token.mint(user1, 1000 ether);

        // New market should work
        vm.prank(newMarket);
        token.mint(user1, 1000 ether);

        assertEq(token.balanceOf(user1), 2000 ether);
    }

    // ========== ERC20 Standard Functionality Tests ==========

    function test_Transfer() public {
        // Setup: mint tokens first
        vm.prank(owner);
        token.setMarketContract(marketContract);

        vm.prank(marketContract);
        token.mint(user1, 1000 ether);

        // Transfer tokens
        vm.prank(user1);
        token.transfer(user2, 400 ether);

        assertEq(token.balanceOf(user1), 600 ether);
        assertEq(token.balanceOf(user2), 400 ether);
    }

    function test_Approve() public {
        vm.prank(owner);
        token.setMarketContract(marketContract);

        vm.prank(marketContract);
        token.mint(user1, 1000 ether);

        vm.prank(user1);
        token.approve(user2, 500 ether);

        assertEq(token.allowance(user1, user2), 500 ether);
    }

    function test_TransferFrom() public {
        vm.prank(owner);
        token.setMarketContract(marketContract);

        vm.prank(marketContract);
        token.mint(user1, 1000 ether);

        vm.prank(user1);
        token.approve(user2, 500 ether);

        vm.prank(user2);
        token.transferFrom(user1, user2, 300 ether);

        assertEq(token.balanceOf(user1), 700 ether);
        assertEq(token.balanceOf(user2), 300 ether);
        assertEq(token.allowance(user1, user2), 200 ether);
    }
}