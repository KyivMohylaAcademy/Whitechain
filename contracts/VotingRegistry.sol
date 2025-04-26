// SPDX-License-Identifier: MIT
// @authors Danyil Melnyk

pragma solidity ^0.8.24;

/// @title VotingRegistry
/// @notice Stores and manages registered voting contracts and their recorded votes
/// @dev Only registered contracts can record or remove votes
contract VotingRegistry {
    address public owner;

    struct VoteInfo {
        address votingContract;
        uint voteId;
    }

    mapping(address => bool) public registeredVotingContracts;
    mapping(address => VoteInfo[]) public votesByContract;
    VoteInfo[] public allVotes;

    event ContractRegistered(address contractAddr);
    event ContractUnregistered(address contractAddr);
    event VoteRecorded(address contractAddr, uint voteId);
    event VoteRemoved(address contractAddr, uint voteId);

    /// @notice Sets the contract deployer as the owner
    constructor() {
        owner = msg.sender;
    }

    /// @notice Restricts function to only be callable by the contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    /// @notice Restricts function to only be callable by a registered contract
    modifier onlyRegistered() {
        require(registeredVotingContracts[msg.sender], "Not a registered contract");
        _;
    }

    /// @notice Registers a new voting contract
    /// @param contractAddr The address of the voting contract to register
    function registerVotingContract(address contractAddr) external onlyOwner {
        registeredVotingContracts[contractAddr] = true;
        emit ContractRegistered(contractAddr);
    }

    /// @notice Unregisters a voting contract
    /// @param contractAddr The address of the voting contract to unregister
    function unregisterVotingContract(address contractAddr) external onlyOwner {
        registeredVotingContracts[contractAddr] = false;
        emit ContractUnregistered(contractAddr);
    }

    /// @notice Records a new vote by a registered voting contract
    /// @param votingContract The contract address where the vote occurred
    /// @param voteId The ID of the vote to record
    function recordVote(address votingContract, uint voteId) external onlyRegistered {
        VoteInfo memory vote = VoteInfo(votingContract, voteId);
        allVotes.push(vote);
        votesByContract[votingContract].push(vote);
        emit VoteRecorded(votingContract, voteId);
    }

    /// @notice Returns a list of all recorded votes
    /// @return An array of VoteInfo structs representing all votes
    function getAllVotes() external view returns (VoteInfo[] memory) {
        return allVotes;
    }

    /// @notice Returns all votes made by a specific contract
    /// @param contractAddr The address of the voting contract
    /// @return An array of VoteInfo structs associated with the contract
    function getVotesByContract(address contractAddr) external view returns (VoteInfo[] memory) {
        return votesByContract[contractAddr];
    }

    /// @notice Removes a specific vote, callable only by its registered voting contract
    /// @param voteId The ID of the vote to remove
    function removeVote(uint voteId) external onlyRegistered {
        VoteInfo[] storage votes = votesByContract[msg.sender];

        for (uint i = 0; i < votes.length; i++) {
            if (votes[i].voteId == voteId) {
                votes[i] = votes[votes.length - 1];
                votes.pop();
                emit VoteRemoved(msg.sender, voteId);
                break;
            }
        }

        for (uint i = 0; i < allVotes.length; i++) {
            if (allVotes[i].voteId == voteId && allVotes[i].votingContract == msg.sender) {
                allVotes[i] = allVotes[allVotes.length - 1];
                allVotes.pop();
                break;
            }
        }
    }
}
