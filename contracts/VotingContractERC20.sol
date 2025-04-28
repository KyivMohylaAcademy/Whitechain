// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract VotingContractERC20 {
    struct Proposal {
        string description;
        uint256 votes;
    }

    IERC20 public token;
    uint256 public minTokens;
    uint256 public votingEnd;

    mapping(address => bool) public hasVoted;
    Proposal[] public proposals;

    event ProposalAdded(uint indexed index, string description);
    event Voted(address indexed voter, uint indexed proposalIndex);

    constructor(address tokenAddress, uint256 _minTokens, uint256 _durationSeconds) {
        token = IERC20(tokenAddress);
        minTokens = _minTokens;
        votingEnd = block.timestamp + _durationSeconds;
    }

    function addProposal(string memory description) public {
        proposals.push(Proposal(description, 0));
        emit ProposalAdded(proposals.length - 1, description);
    }

    function vote(uint proposalIndex) public {
        require(block.timestamp < votingEnd, "Voting has ended");
        require(!hasVoted[msg.sender], "Already voted");
        require(token.balanceOf(msg.sender) >= minTokens, "Insufficient token balance");
        require(proposalIndex < proposals.length, "Invalid proposal index");

        proposals[proposalIndex].votes += 1;
        hasVoted[msg.sender] = true;

        emit Voted(msg.sender, proposalIndex);
    }

    function getProposals() public view returns (Proposal[] memory) {
        return proposals;
    }

    function winningProposal() public view returns (string memory winner) {
        uint maxVotes = 0;
        winner = "";
        for (uint i = 0; i < proposals.length; i++) {
            if (proposals[i].votes > maxVotes) {
                maxVotes = proposals[i].votes;
                winner = proposals[i].description;
            }
        }
    }
}
