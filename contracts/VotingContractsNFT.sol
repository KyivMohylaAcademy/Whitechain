// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IERC721 {
    function balanceOf(address owner) external view returns (uint256);
}

contract VotingContractNFT {
    struct Voting {
        string title;
        bool active;
        uint startTime;
        uint endTime;
        uint optionsCount;
        mapping(uint => string) options;
        mapping(uint => uint) votes;
        mapping(address => bool) hasVoted;
    }

    address public owner;
    IERC721 public nftContract;
    uint public votingCount;

    mapping(uint => Voting) public votings;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can do this");
        _;
    }

    constructor(address _nftAddress) {
        owner = msg.sender;
        nftContract = IERC721(_nftAddress);
    }

    function createVoting(string memory _title, string[] memory _options, uint _durationSeconds) external onlyOwner {
        Voting storage v = votings[votingCount];
        v.title = _title;
        v.startTime = block.timestamp;
        v.endTime = block.timestamp + _durationSeconds;
        v.active = true;
        v.optionsCount = _options.length;

        for (uint i = 0; i < _options.length; i++) {
            v.options[i] = _options[i];
            v.votes[i] = 0;
        }

        votingCount++;
    }

    function vote(uint _votingId, uint _optionId) external {
        Voting storage v = votings[_votingId];

        require(v.active, "Voting is not active");
        require(block.timestamp < v.endTime, "Voting has ended");
        require(!v.hasVoted[msg.sender], "Already voted");
        require(nftContract.balanceOf(msg.sender) > 0, "Must own at least one NFT");
        require(_optionId < v.optionsCount, "Invalid option");

        v.votes[_optionId]++;
        v.hasVoted[msg.sender] = true;
    }

    function endVoting(uint _votingId) external onlyOwner {
        Voting storage v = votings[_votingId];
        require(v.active, "Already ended");
        v.active = false;
    }

    function getWinner(uint _votingId) external view returns (string memory winner, uint votes) {
        Voting storage v = votings[_votingId];
        uint maxVotes = 0;
        uint winnerId = 0;

        for (uint i = 0; i < v.optionsCount; i++) {
            if (v.votes[i] > maxVotes) {
                maxVotes = v.votes[i];
                winnerId = i;
            }
        }

        return (v.options[winnerId], maxVotes);
    }

    function getOption(uint _votingId, uint _optionId) public view returns (string memory, uint) {
        Voting storage v = votings[_votingId];
        require(_optionId < v.optionsCount, "Invalid option");
        return (v.options[_optionId], v.votes[_optionId]);
    }

    function hasAddressVoted(uint _votingId, address _user) public view returns (bool) {
        return votings[_votingId].hasVoted[_user];
    }

    function getVotingDetails(uint _votingId) public view returns (
        string memory title,
        bool active,
        uint endTime,
        uint optionsCount
    ) {
        Voting storage v = votings[_votingId];
        return (v.title, v.active, v.endTime, v.optionsCount);
    }
}
