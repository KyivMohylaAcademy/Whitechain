// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title Voting Contract with NFT Rewards
 * @notice Контракт для голосування з винагородою у вигляді NFT
 */

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IVotingRegistry.sol";
import "./interfaces/INFTContract.sol";
import "./interfaces/IVotingContract.sol";

contract VotingContract is IVotingContract, Ownable {
    uint256 private _votingIds;
    
    IVotingRegistry public votingRegistry;
    INFTContract public nftContract;
    
    struct Voting {
        uint256 id;
        string description;
        uint256 startTime;
        uint256 endTime;
        uint256 option1Votes;
        uint256 option2Votes;
        string option1;
        string option2;
        bool isActive;
        mapping(address => bool) hasVoted;
    }
    
    mapping(uint256 => Voting) public votings;
    mapping(uint256 => address[]) public votingParticipants;
    
    event VotingCreated(uint256 indexed votingId, string description, uint256 startTime, uint256 endTime);
    event Voted(uint256 indexed votingId, address indexed voter, uint8 option);
    event NFTRewarded(address indexed voter, uint256 tokenId);
    
    constructor(address _votingRegistry, address _nftContract) Ownable(msg.sender) {
        votingRegistry = IVotingRegistry(_votingRegistry);
        nftContract = INFTContract(_nftContract);
    }
    
    /**
     * @notice Створити нове голосування
     * @param description Опис голосування
     * @param durationInMinutes Тривалість голосування у хвилинах
     * @param _option1 Перший варіант відповіді
     * @param _option2 Другий варіант відповіді
     */
    function createVoting(
        string memory description,
        uint256 durationInMinutes,
        string memory _option1,
        string memory _option2
    ) external onlyOwner {
        require(!isActiveVoting(), "Active voting exists");
        
        uint256 newVotingId = _votingIds;
        uint256 startTime = block.timestamp;
        uint256 endTime = startTime + (durationInMinutes * 1 minutes);
        
        Voting storage newVoting = votings[newVotingId];
        newVoting.id = newVotingId;
        newVoting.description = description;
        newVoting.startTime = startTime;
        newVoting.endTime = endTime;
        newVoting.option1 = _option1;
        newVoting.option2 = _option2;
        newVoting.isActive = true;
        
        votingRegistry.addVoting(address(this), newVotingId, description, startTime, endTime);
        
        emit VotingCreated(newVotingId, description, startTime, endTime);
        
        _votingIds += 1;
    }
    
    /**
     * @notice Голосувати за варіант
     * @param votingId ID голосування
     * @param option Обраний варіант (1 або 2)
     */
    function vote(uint256 votingId, uint8 option) external {
        require(isRegistered(), "Contract not registered in registry");
        require(votings[votingId].isActive, "Voting is not active");
        require(block.timestamp >= votings[votingId].startTime, "Voting not started");
        require(block.timestamp <= votings[votingId].endTime, "Voting ended");
        require(!votings[votingId].hasVoted[msg.sender], "Already voted");
        require(option == 1 || option == 2, "Invalid option");
        
    
        if (option == 1) {
            votings[votingId].option1Votes++;
        } else {
            votings[votingId].option2Votes++;
        }
        
        votings[votingId].hasVoted[msg.sender] = true;
        votingParticipants[votingId].push(msg.sender);
        
        uint256 tokenId = nftContract.mintReward(msg.sender);
        
        emit Voted(votingId, msg.sender, option);
        emit NFTRewarded(msg.sender, tokenId);
    }
    
    /**
     * @notice Перевірка чи закінчилось голосування
     * @param votingId ID голосування
     */
    function finishVoting(uint256 votingId) external onlyOwner {
        require(votings[votingId].isActive, "Voting not active");
        require(block.timestamp > votings[votingId].endTime, "Voting still active");
        
        votings[votingId].isActive = false;
        
        votingRegistry.updateVotingStatus(address(this), votingId, false);
    }
    
    /**
     * @notice Перевірка результатів голосування
     * @param votingId ID голосування
     * @return winner Переможець (1 або 2) або 0 якщо нічия
     * @return option1Votes Кількість голосів за перший варіант
     * @return option2Votes Кількість голосів за другий варіант
     */
    function getVotingResults(uint256 votingId) external view returns (uint8 winner, uint256 option1Votes, uint256 option2Votes) {
        require(votingId < _votingIds, "Invalid voting ID");
        
        option1Votes = votings[votingId].option1Votes;
        option2Votes = votings[votingId].option2Votes;
        
        if (option1Votes > option2Votes) {
            winner = 1;
        } else if (option2Votes > option1Votes) {
            winner = 2;
        } else {
            winner = 0;
        }
        
        return (winner, option1Votes, option2Votes);
    }
    
    /**
     * @notice Отримати деталі голосування
     * @param votingId ID голосування
     */
    function getVotingDetails(uint256 votingId) external view returns (
        string memory description,
        uint256 startTime,
        uint256 endTime,
        string memory option1,
        string memory option2,
        bool isActive
    ) {
        require(votingId < _votingIds, "Invalid voting ID");
        
        Voting storage v = votings[votingId];
        return (
            v.description,
            v.startTime,
            v.endTime,
            v.option1,
            v.option2,
            v.isActive
        );
    }
    
    /**
     * @notice Перевірка чи є активне голосування
     */
    function isActiveVoting() public view returns (bool) {
        for (uint256 i = 0; i < _votingIds; i++) {
            if (votings[i].isActive && block.timestamp <= votings[i].endTime) {
                return true;
            }
        }
        return false;
    }
    
    /**
     * @notice Перевірка чи зареєстрований контракт у реєстрі
     */
    function isRegistered() public view returns (bool) {
        return votingRegistry.isVotingContractRegistered(address(this));
    }
    
    /**
     * @notice Отримати поточний ID голосування
     */
    function getCurrentVotingId() external view returns (uint256) {
        return _votingIds;
    }
    
    /**
     * @notice Перевірка чи проголосував користувач
     * @param votingId ID голосування
     * @param voter Адреса користувача
     */
    function hasVoted(uint256 votingId, address voter) external view returns (bool) {
        return votings[votingId].hasVoted[voter];
    }
    
    /**
     * @notice Отримати учасників голосування
     * @param votingId ID голосування
     */
    function getVotingParticipants(uint256 votingId) external view returns (address[] memory) {
        return votingParticipants[votingId];
    }
}