// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Реєстр голосувань
 * @notice Зберігає інформацію про всі контракти голосування та голосування в них
 */
contract VotingRegistry is Ownable {
    struct Voting {
        uint256 id;
        string description;
        uint256 startTime;
        uint256 endTime;
        bool isActive;
    }

    struct VotingContractInfo {
        address contractAddress;
        address owner;
        bool isActive;
        uint256[] votingIds;
    }

    mapping(address => VotingContractInfo) private _votingContracts;
    
    address[] private _registeredContracts;
    
    mapping(address => mapping(uint256 => Voting)) private _votings;
    
    event VotingContractAdded(address indexed contractAddress, address indexed owner);
    event VotingContractRemoved(address indexed contractAddress);
    event VotingAdded(address indexed contractAddress, uint256 indexed votingId, string description);
    event VotingUpdated(address indexed contractAddress, uint256 indexed votingId, bool isActive);
    
    constructor() Ownable(msg.sender) {}
    
    /**
     * @notice Додати контракт голосування в реєстр
     * @param votingContract Адреса контракту голосування
     */
    function addVotingContract(address votingContract) external {
        require(votingContract != address(0), "Invalid contract address");
        require(!_votingContracts[votingContract].isActive, "Contract already registered");
        
        _votingContracts[votingContract] = VotingContractInfo({
            contractAddress: votingContract,
            owner: msg.sender,
            isActive: true,
            votingIds: new uint256[](0)
        });
        
        _registeredContracts.push(votingContract);
        
        emit VotingContractAdded(votingContract, msg.sender);
    }
    
    /**
     * @notice Видалити контракт голосування з реєстру
     * @param votingContract Адреса контракту голосування
     */
    function removeVotingContract(address votingContract) external {
        require(_votingContracts[votingContract].isActive, "Contract not registered");
        require(_votingContracts[votingContract].owner == msg.sender, "Not contract owner");
        
        _votingContracts[votingContract].isActive = false;
        
        emit VotingContractRemoved(votingContract);
    }
    
    /**
     * @notice Додати голосування до реєстру
     * @param votingContract Адреса контракту голосування
     * @param votingId ID голосування
     * @param description Опис голосування
     * @param startTime Час початку голосування
     * @param endTime Час кінця голосування
     */
    function addVoting(
        address votingContract,
        uint256 votingId,
        string memory description,
        uint256 startTime,
        uint256 endTime
    ) external {
        require(_votingContracts[votingContract].isActive, "Contract not registered");
        require(msg.sender == votingContract, "Only voting contract can add voting");
        
        Voting memory newVoting = Voting({
            id: votingId,
            description: description,
            startTime: startTime,
            endTime: endTime,
            isActive: true
        });
        
        _votings[votingContract][votingId] = newVoting;
        _votingContracts[votingContract].votingIds.push(votingId);
        
        emit VotingAdded(votingContract, votingId, description);
    }
    
    /**
     * @notice Оновити статус голосування
     * @param votingContract Адреса контракту голосування
     * @param votingId ID голосування
     * @param isActive Чи активне голосування
     */
    function updateVotingStatus(
        address votingContract,
        uint256 votingId,
        bool isActive
    ) external {
        require(_votingContracts[votingContract].isActive, "Contract not registered");
        require(msg.sender == votingContract, "Only voting contract can update status");
        require(_votings[votingContract][votingId].id == votingId, "Voting not found");
        
        _votings[votingContract][votingId].isActive = isActive;
        
        emit VotingUpdated(votingContract, votingId, isActive);
    }
    
    /**
     * @notice Перевірити чи зареєстрований контракт
     * @param votingContract Адреса контракту голосування
     */
    function isVotingContractRegistered(address votingContract) external view returns (bool) {
        return _votingContracts[votingContract].isActive;
    }
    
    /**
     * @notice Отримати всі зареєстровані контракти голосування
     */
    function getAllVotingContracts() external view returns (address[] memory) {
        return _registeredContracts;
    }
    
    /**
     * @notice Отримати деталі контракту голосування
     * @param votingContract Адреса контракту голосування
     */
    function getVotingContractInfo(address votingContract) external view returns (
        address contractAddress,
        address owner,
        bool isActive,
        uint256[] memory votingIds
    ) {
        VotingContractInfo storage info = _votingContracts[votingContract];
        return (
            info.contractAddress,
            info.owner,
            info.isActive,
            info.votingIds
        );
    }
    
    /**
     * @notice Отримати деталі голосування
     * @param votingContract Адреса контракту голосування
     * @param votingId ID голосування
     */
    function getVotingDetails(address votingContract, uint256 votingId) external view returns (
        uint256 id,
        string memory description,
        uint256 startTime,
        uint256 endTime,
        bool isActive
    ) {
        Voting storage voting = _votings[votingContract][votingId];
        require(voting.id == votingId, "Voting not found");
        
        return (
            voting.id,
            voting.description,
            voting.startTime,
            voting.endTime,
            voting.isActive
        );
    }
    
    /**
     * @notice Отримати кількість голосувань для контракту
     * @param votingContract Адреса контракту голосування
     */
    function getVotingCount(address votingContract) external view returns (uint256) {
        return _votingContracts[votingContract].votingIds.length;
    }
}