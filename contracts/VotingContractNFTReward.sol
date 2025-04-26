// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./RewardNFT.sol";
import "./VotingRegistry.sol";

/// @title Voting Contract with NFT Reward
/// @notice Manages votes and distributes NFTs to voters
/// @dev Integrates RewardNFT and VotingRegistry contracts
contract VotingContractNFTReward {
    struct Vote {
        string[] options;
        mapping(uint => uint) voteCounts;
        mapping(address => bool) hasVoted;
        uint endTime;
        bool exists;
    }

    address public owner;
    VotingRegistry public registry;
    RewardNFT public nft;
    uint public currentVoteId;
    mapping(uint => Vote) public votes;

    /// @notice Restricts access to the contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    /// @notice Initializes contract with NFT and registry addresses
    /// @param _nft Address of the deployed RewardNFT contract
    /// @param _registry Address of the deployed VotingRegistry contract
    constructor(address _nft, address _registry) {
        nft = RewardNFT(_nft);
        registry = VotingRegistry(_registry);
        owner = msg.sender;
    }

    /// @notice Creates a new vote with options and duration
    /// @param _options List of voting options
    /// @param durationSeconds Duration of the vote in seconds
    function createVote(string[] memory _options, uint durationSeconds) external onlyOwner {
        currentVoteId++;
        Vote storage v = votes[currentVoteId];
        v.options = _options;
        v.endTime = block.timestamp + durationSeconds;
        v.exists = true;

        registry.recordVote(address(this), currentVoteId);
    }

    /// @notice Allows an address to vote and receive an NFT reward
    /// @param voteId ID of the vote
    /// @param optionIndex Index of the selected voting option
    function vote(uint voteId, uint optionIndex) external {
        Vote storage v = votes[voteId];
        require(v.exists, "Vote does not exist");
        require(block.timestamp < v.endTime, "Voting ended");
        require(!v.hasVoted[msg.sender], "Already voted");
        require(optionIndex < v.options.length, "Invalid option");

        v.hasVoted[msg.sender] = true;
        v.voteCounts[optionIndex]++;

        nft.mint(msg.sender); // reward voter with NFT
    }

    /// @notice Retrieves the results of a finished vote
    /// @param voteId ID of the vote
    /// @return Array of vote counts per option
    function getResults(uint voteId) external view returns (uint[] memory) {
        Vote storage v = votes[voteId];
        require(block.timestamp >= v.endTime, "Voting still ongoing");

        uint[] memory counts = new uint[](v.options.length);
        for (uint i = 0; i < v.options.length; i++) {
            counts[i] = v.voteCounts[i];
        }
        return counts;
    }

    /// @notice Retrieves the voting options for a given vote
    /// @param voteId ID of the vote
    /// @return Array of option strings
    function getOptions(uint voteId) external view returns (string[] memory) {
        return votes[voteId].options;
    }
}
