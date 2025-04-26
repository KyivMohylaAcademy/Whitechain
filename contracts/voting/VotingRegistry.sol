// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract VotingRegistry {
    address public owner;
    mapping(address => bool) public registeredVotingContracts;
    address[] public allVotingContracts;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can modify the registry.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    // Register a new VotingContract
    function registerVotingContract(address _votingContract) public onlyOwner {
        require(!registeredVotingContracts[_votingContract], "Contract is already registered.");
        registeredVotingContracts[_votingContract] = true;
        allVotingContracts.push(_votingContract);
    }

    // Unregister a VotingContract
    function unregisterVotingContract(address _votingContract) public onlyOwner {
        require(registeredVotingContracts[_votingContract], "Contract not registered.");
        
        // Mark as unregistered
        registeredVotingContracts[_votingContract] = false;
        
        // Remove the contract from the allVotingContracts array
        for (uint i = 0; i < allVotingContracts.length; i++) {
            if (allVotingContracts[i] == _votingContract) {
                // Move the last element to the position of the element to be removed
                allVotingContracts[i] = allVotingContracts[allVotingContracts.length - 1];
                allVotingContracts.pop();
                break;
            }
        }
    }

    // Get all registered voting contracts
    function getAllVotingContracts() public view returns (address[] memory) {
        return allVotingContracts;
    }
}
