// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IVotingRegistry {
    function addVotingContract(address votingContract) external;
    function removeVotingContract(address votingContract) external;
    function addVoting(address votingContract, uint256 votingId, string memory description, uint256 startTime, uint256 endTime) external;
    function updateVotingStatus(address votingContract, uint256 votingId, bool isActive) external;
    function isVotingContractRegistered(address votingContract) external view returns (bool);
}