// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Interface for the NFT contract (Assume it has balanceOf function)
interface INFT {
    function balanceOf(address owner) external view returns (uint256);
}

contract VotingContract {

    address public admin;
    INFT public nftContract; // Address of the NFT contract
    uint256 public startTime;
    uint256 public endTime;

    // Mapping to track if an address has voted
    mapping(address => bool) public hasVoted;

    // Events for logging
    event Voted(address indexed voter);
    event VotingFinalized(address indexed admin);
    
    // Constructor to initialize the contract
    constructor(address _nftContract, uint256 _startTime, uint256 _endTime) {
        admin = msg.sender;
        nftContract = INFT(_nftContract);
        startTime = _startTime;
        endTime = _endTime;
    }

    // Modifier to ensure the function is only called during the voting period
    modifier onlyDuringVotingPeriod() {
        require(block.timestamp >= startTime && block.timestamp <= endTime, "Voting is not allowed at this time.");
        _;
    }

    // Modifier to check if the voter owns at least one NFT
    modifier onlyIfOwnsNFT(address voter) {
        require(nftContract.balanceOf(voter) > 0, "You must own at least one NFT to vote.");
        _;
    }

    // Function to vote (can only be called during the voting period and by NFT owners)
    function vote() external onlyDuringVotingPeriod onlyIfOwnsNFT(msg.sender) {
        require(!hasVoted[msg.sender], "You have already voted.");
        hasVoted[msg.sender] = true;
        emit Voted(msg.sender);
    }

    // Function to finalize the voting (can only be called by admin after the voting period ends)
    function finalizeVoting() external onlyAfterVotingPeriod onlyAdmin {
        // Logic for finalizing voting (e.g., counting votes, determining the winner)
        emit VotingFinalized(msg.sender);
    }

    // Modifier to ensure only the admin can call the function
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only the admin can finalize the vote.");
        _;
    }

    // Modifier to ensure that the function can only be called after the voting period ends
    modifier onlyAfterVotingPeriod() {
        require(block.timestamp > endTime, "Voting period has not ended.");
        _;
    }
}
