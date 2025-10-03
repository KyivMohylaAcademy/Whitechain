// SPDX-License-Identifier: MIT
pragma solidity ~0.8.25;

import {Test} from "forge-std/Test.sol";
import "../src/ResourceSearch.sol";

contract ResourceSearchTest is Test {
    Resource public resource;
    ResourceSearch public resourceSearch;
    
    address public user1 = address(0x1);
    address public user2 = address(0x2);
    address public user3 = address(0x3);
    
    uint64 public constant SEARCH_PERIOD_SECONDS = 60;
    uint8 public constant RESOURCES_FARMED_PER_SEARCH = 3;
    
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    /**
     * Slightly changed version of the contract not secure pseudo random generator, so testing can be determinisitc.
     */
    function contractRandomResourceDistribution(address sender, uint256 timestamp, uint256 blockPrevrandao)
         internal pure returns (uint256[] memory) {
        uint256[] memory foundResources = new uint256[](uint256(type(ResourceSearch.Type).max) + 1);
        for(uint i=0; i < RESOURCES_FARMED_PER_SEARCH; i++) {
            uint256 pseudoRandomNumber = uint256(keccak256(abi.encodePacked(timestamp, sender, blockPrevrandao, i)));
            uint256 resourceIndex = pseudoRandomNumber % (uint256(type(ResourceSearch.Type).max) + 1);
            foundResources[resourceIndex] += 1;
        }
        
        return foundResources; 
    }

    function accumulateResourceDistribution(uint256[] memory prevResources, address sender, uint256 timestamp, uint256 blockPrevrandao) 
      internal pure returns (uint256[] memory) {
        uint256[] memory foundResources = new uint256[](prevResources.length);
        uint256[] memory expectedNext = contractRandomResourceDistribution(sender, timestamp, blockPrevrandao);
        for (uint j = 0; j < expectedNext.length; j++) {
            foundResources[j] = expectedNext[j] + prevResources[j];
        }

        return foundResources;
    }
    
    function setUp() public {
        // Give users some ETH for gas
        vm.deal(user1, 100 ether);
        vm.deal(user2, 100 ether);
        vm.deal(user3, 100 ether);

        resource = new Resource(user3);
        resourceSearch = new ResourceSearch(address(resource));

        vm.prank(user3);
        resource.setSearchContract(address(resourceSearch));
        vm.stopPrank();

        vm.warp(1759410618);
    }
    
    /**************************************************************************
     * Basic Functionality Tests
     **************************************************************************/
    
    function test_SearchSucceedsOnFirstCall() public {
        vm.prank(user1);
        resourceSearch.search();
        uint256[] memory expected = contractRandomResourceDistribution(user1, vm.getBlockTimestamp(), 0);
        
        for (uint i = 0; i < expected.length; i++) {
            uint256 balance = resource.balanceOf(user1, i);
            assertEq(balance, expected[i]);
        }
    }
    
    function test_SearchSucceedsAfter60Seconds() public {
        // First search
        vm.prank(user1);
        resourceSearch.search();
        uint256[] memory expected = contractRandomResourceDistribution(user1, vm.getBlockTimestamp(), 0);
        
        // Fast forward 60 seconds
        vm.warp(block.timestamp + SEARCH_PERIOD_SECONDS);
        
        // Second search should succeed
        vm.prank(user1);
        resourceSearch.search();
        expected = accumulateResourceDistribution(expected, user1, vm.getBlockTimestamp(), 0);
        
        uint256 overallResourcesFarmed = 0;
        for (uint i = 0; i < expected.length; i++) {
            uint256 balance = resource.balanceOf(user1, i);
            assertEq(balance, expected[i]);
            overallResourcesFarmed += balance; 
        } 

        assertEq(6, overallResourcesFarmed);
    }
    
    function test_SearchRevertsBeforeCooldown() public {
        vm.startPrank(user1);
        resourceSearch.search();
        
        // Try to search immediately
        vm.expectRevert();
        resourceSearch.search();
        vm.stopPrank();
    }
    
    function test_SearchRevertsAt59Seconds() public {
        vm.startPrank(user1);
        resourceSearch.search();
        
        // Fast forward 59 seconds (just before cooldown ends)
        vm.warp(block.timestamp + 59);
        
        vm.expectRevert();
        resourceSearch.search();
        vm.stopPrank();
    }
    
    function test_SearchSucceedsAtExactly60Seconds() public {
        vm.startPrank(user1);
        resourceSearch.search();
        
        // Fast forward exactly 60 seconds
        vm.warp(block.timestamp + SEARCH_PERIOD_SECONDS);
        
        // Should succeed
        resourceSearch.search();
        vm.stopPrank();
    }
    
    function test_SearchSucceedsAfter61Seconds() public {
        vm.startPrank(user1);
        resourceSearch.search();
        
        // Fast forward 61 seconds
        vm.warp(block.timestamp + 61);
        
        resourceSearch.search();
        vm.stopPrank();
    }
    
    /**************************************************************************
     * Resource Minting Tests
     **************************************************************************/
    
    function test_SearchMints3Resources() public {
        vm.prank(user1);
        resourceSearch.search();
        uint256[] memory expected = contractRandomResourceDistribution(user1, vm.getBlockTimestamp(), 0);
        
        uint actualNumberOfMinted = 0;
        for (uint i = 0; i < expected.length; i++) {
            actualNumberOfMinted += resource.balanceOf(user1, i);
        }

        assertEq(3, actualNumberOfMinted);
    }
    
    function test_SearchMintsCorrectAmounts() public {
        vm.prank(user1);
        resourceSearch.search();
        uint256[] memory expected = contractRandomResourceDistribution(user1, vm.getBlockTimestamp(), 0);

        for (uint i = 0; i < expected.length; i++) {
            uint256 balance = resource.balanceOf(user1, i);
            assertEq(balance, expected[i]);
        }
    }
    
    function test_SearchEmitsTransferBatchEvent() public {
        vm.prank(user1);
        
        // Expect TransferBatch event
        vm.expectEmit(true, true, true, false, address(resource));
        emit TransferBatch(address(resourceSearch), address(0), user1, new uint256[](3), new uint256[](3));
        
        resourceSearch.search();
    }
    
    /**************************************************************************
     * Multiple User Tests
     **************************************************************************/
    
    function test_DifferentUsersCanSearchIndependently() public {
        // User1 searches
        vm.prank(user1);
        resourceSearch.search();
        uint256[] memory u1Expected = contractRandomResourceDistribution(user1, vm.getBlockTimestamp(), 0);
        
        // User2 should be able to search immediately
        vm.prank(user2);
        resourceSearch.search();
        uint256[] memory u2Expected = contractRandomResourceDistribution(user2, vm.getBlockTimestamp(), 0);

        for (uint i = 0; i < u1Expected.length; i++) {
             // Both should have resources
            assertEq(resource.balanceOf(user1, i), u1Expected[i]);
            assertEq(resource.balanceOf(user2, i), u2Expected[i]);
        }         
    }
    
    function test_User1CooldownDoesNotAffectUser2() public {
        // User1 searches
        vm.prank(user1);
        resourceSearch.search();
        
        // Fast forward 30 seconds
        vm.warp(block.timestamp + 30);
        
        // User1 cannot search yet
        vm.prank(user1);
        vm.expectRevert();
        resourceSearch.search();
        
        // But user2 can search
        vm.prank(user2);
        resourceSearch.search();
    }
    
    function test_MultipleUsersMultipleSearches() public {
        // User1 first search
        vm.prank(user1);
        resourceSearch.search();
        uint256[] memory u1Expected = contractRandomResourceDistribution(user1, vm.getBlockTimestamp(), 0);
        
        // User2 first search
        vm.prank(user2);
        resourceSearch.search();
        uint256[] memory u2Expected = contractRandomResourceDistribution(user2, vm.getBlockTimestamp(), 0);
        
        // Fast forward
        vm.warp(block.timestamp + SEARCH_PERIOD_SECONDS);
        
        // Both can search again
        vm.prank(user1);
        resourceSearch.search();
        u1Expected = accumulateResourceDistribution(u1Expected, user1, vm.getBlockTimestamp(), 0);
        
        vm.prank(user2);
        resourceSearch.search();
        u2Expected = accumulateResourceDistribution(u2Expected, user2, vm.getBlockTimestamp(), 0);
        
        for (uint i = 0; i < u1Expected.length; i++) {
             // Both should have resources
            assertEq(resource.balanceOf(user1, i), u1Expected[i]);
            assertEq(resource.balanceOf(user2, i), u2Expected[i]);
        }     
    }
    
    /**************************************************************************
     * Time Calculation Tests
     **************************************************************************/
    
    function test_CalculateTimePassedForNewUser() public {
        vm.prank(user1);
        uint256 timePassed = resourceSearch.calculateTimePassedSinceLastSearch();
        
        // Should return current block.timestamp (since _lastTimeSearch[user1] = 0)
        assertEq(timePassed, block.timestamp);
    }
    
    function test_CalculateTimePassedImmediatelyAfterSearch() public {
        vm.prank(user1);
        resourceSearch.search();
        
        vm.prank(user1);
        uint256 timePassed = resourceSearch.calculateTimePassedSinceLastSearch();
        
        assertEq(timePassed, 0);
    }
    
    function test_CalculateTimePassedAfter30Seconds() public {
        vm.prank(user1);
        resourceSearch.search();
        
        vm.warp(block.timestamp + 30);
        
        vm.prank(user1);
        uint256 timePassed = resourceSearch.calculateTimePassedSinceLastSearch();
        
        assertEq(timePassed, 30);
    }
    
    function test_CalculateTimePassedAfter60Seconds() public {
        vm.prank(user1);
        resourceSearch.search();
        
        vm.warp(block.timestamp + 60);
        
        vm.prank(user1);
        uint256 timePassed = resourceSearch.calculateTimePassedSinceLastSearch();
        
        assertEq(timePassed, 60);
    }
    
    function test_CalculateTimePassedForDifferentUsers() public {
        // User1 searches
        vm.prank(user1);
        resourceSearch.search();
        
        // Fast forward 30 seconds
        vm.warp(block.timestamp + 30);
        
        // User2 searches
        vm.prank(user2);
        resourceSearch.search();
        
        // Fast forward another 20 seconds
        vm.warp(block.timestamp + 20);
        
        // Check time passed for each user
        vm.prank(user1);
        uint256 user1TimePassed = resourceSearch.calculateTimePassedSinceLastSearch();
        assertEq(user1TimePassed, 50);
        
        vm.prank(user2);
        uint256 user2TimePassed = resourceSearch.calculateTimePassedSinceLastSearch();
        assertEq(user2TimePassed, 20);
    }
    
    /**************************************************************************
     * Edge Case Tests
     **************************************************************************/
    
    function test_MultipleConsecutiveSearches() public {
        vm.startPrank(user1);
        
        // First search
        resourceSearch.search();
        uint256[] memory expected = contractRandomResourceDistribution(user1, vm.getBlockTimestamp(), 0);
        
        // Second search after cooldown
        vm.warp(block.timestamp + SEARCH_PERIOD_SECONDS);
        expected = accumulateResourceDistribution(expected, user1, vm.getBlockTimestamp(), 0);
        resourceSearch.search();
        
        // Third search after cooldown
        vm.warp(block.timestamp + SEARCH_PERIOD_SECONDS);
        expected = accumulateResourceDistribution(expected, user1, vm.getBlockTimestamp(), 0);
        resourceSearch.search();
        
        vm.stopPrank();

        for (uint i = 0; i < expected.length; i++) {
            assertEq(resource.balanceOf(user1, i), expected[i]);
        } 
    }
    
    function test_SearchAfterLongPeriod() public {
        vm.startPrank(user1);
        resourceSearch.search();
        uint256[] memory expected = contractRandomResourceDistribution(user1, vm.getBlockTimestamp(), 0);
        
        // Fast forward 1 year
        vm.warp(block.timestamp + 365 days);
        
        resourceSearch.search();
        expected = accumulateResourceDistribution(expected, user1, vm.getBlockTimestamp(), 0);
        vm.stopPrank();
        
        for (uint i = 0; i < expected.length; i++) {
            assertEq(resource.balanceOf(user1, i), expected[i]);
        } 
    }
    
    function test_SearchAtBlockchainStartTime() public {
        // This tests the edge case where _lastTimeSearch is 0
        vm.warp(1000); // Set to some arbitrary time
        
        vm.prank(user1);
        resourceSearch.search();
        uint256[] memory expected = contractRandomResourceDistribution(user1, vm.getBlockTimestamp(), 0);
        
        for (uint i = 0; i < expected.length; i++) {
            assertEq(resource.balanceOf(user1, i), expected[i]);
        } 
    }
    
    /**************************************************************************
     * Fuzz Tests
     **************************************************************************/
    
    function testFuzz_SearchAfterVariableTime(uint256 timeToWarp) public {
        // Bound the time to reasonable values
        timeToWarp = bound(timeToWarp, SEARCH_PERIOD_SECONDS, 365 days);
        
        vm.startPrank(user1);
        resourceSearch.search();
        uint256[] memory expected = contractRandomResourceDistribution(user1, vm.getBlockTimestamp(), 0);
        
        vm.warp(block.timestamp + timeToWarp);
        resourceSearch.search();
        expected = accumulateResourceDistribution(expected, user1, vm.getBlockTimestamp(), 0);
        vm.stopPrank();
        
        for (uint i = 0; i < expected.length; i++) {
            assertEq(resource.balanceOf(user1, i), expected[i]);
        } 
    }
    
    function testFuzz_SearchFailsBeforeCooldown(uint256 timeToWarp) public {
        // Bound the time to values less than cooldown period
        timeToWarp = bound(timeToWarp, 0, SEARCH_PERIOD_SECONDS - 1);
        
        vm.startPrank(user1);
        resourceSearch.search();
        
        vm.warp(block.timestamp + timeToWarp);
        
        vm.expectRevert();
        resourceSearch.search();
        vm.stopPrank();
    }
    
    function testFuzz_MultipleUserSearches(address userAddr) public {
        // Ensure address is valid
        vm.assume(userAddr != address(0));
        vm.assume(userAddr != address(this));
        
        vm.prank(userAddr);
        resourceSearch.search();
        uint256[] memory expected = contractRandomResourceDistribution(userAddr, vm.getBlockTimestamp(), 0);
        
        for (uint i = 0; i < expected.length; i++) {
            assertEq(resource.balanceOf(userAddr, i), expected[i]);
        } 
    }
    
    /**************************************************************************
     * Integration Tests
     **************************************************************************/
    
    function test_ResourceAccumulationOverTime() public {
        vm.startPrank(user1);
        
        uint256[] memory expected = contractRandomResourceDistribution(user1, vm.getBlockTimestamp(), 0);
        // Perform 5 searches over time
        for (uint i = 0; i < 5; i++) {
            resourceSearch.search();

            for (uint k = 0; k < expected.length; k++) {
                assertEq(resource.balanceOf(user1, i), expected[i]);
            }    
            // Fast forward for next iteration
            if (i < 4) {
                vm.warp(block.timestamp + SEARCH_PERIOD_SECONDS);
                expected = accumulateResourceDistribution(expected, user1, vm.getBlockTimestamp(), 0);
            }
        }
        
        vm.stopPrank();
    }
    
    function test_TimestampUpdateAfterSearch() public {
        vm.startPrank(user1);
        
        resourceSearch.search();
        
        vm.warp(block.timestamp + SEARCH_PERIOD_SECONDS);
        resourceSearch.search();
        
        // Time passed should be 0 immediately after search
        uint256 timePassed = resourceSearch.calculateTimePassedSinceLastSearch();
        assertEq(timePassed, 0);
        
        vm.stopPrank();
    }
}