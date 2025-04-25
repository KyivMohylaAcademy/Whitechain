// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IVotingContract {
    function createVoting(
        string memory description,
        uint256 durationInMinutes,
        string memory option1,
        string memory option2
    ) external;
    
    function vote(uint256 votingId, uint8 option) external;
    
    function getVotingResults(uint256 votingId) external view returns (uint8 winner, uint256 option1Votes, uint256 option2Votes);
    
    function hasVoted(uint256 votingId, address voter) external view returns (bool);
}