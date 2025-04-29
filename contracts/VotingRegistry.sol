// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title VotingRegistry
 * @dev Реєстр голосувань для зберігання інформації про всі голосування
 * @author Ваше ім'я
 */
contract VotingRegistry is Ownable {
    // Структура для зберігання інформації про контракт голосування
    struct VotingContractInfo {
        address contractAddress;
        address owner;
        bool isActive;
    }
    
    // Структура для зберігання інформації про голосування
    struct VotingInfo {
        address contractAddress;
        uint256 votingId;
        bool isActive;
    }
    
    // Маппінг для зберігання всіх контрактів голосування
    mapping(address => VotingContractInfo) public votingContracts;
    
    // Масив адрес контрактів голосування
    address[] public votingContractAddresses;
    
    // Маппінг для зберігання всіх голосувань
    mapping(uint256 => VotingInfo) public votings;
    
    // Маппінг для зберігання голосувань по контрактам
    mapping(address => uint256[]) public contractVotings;
    
    // Лічильник голосувань
    uint256 public votingsCount;
    
    // Події
    event VotingContractAdded(address indexed contractAddress, address indexed owner);
    event VotingContractRemoved(address indexed contractAddress);
    event VotingAdded(uint256 indexed votingId, address indexed contractAddress, uint256 votingIdInContract);
    event VotingRemoved(uint256 indexed votingId);
    
    /**
     * @dev Конструктор
     */
    constructor() Ownable(msg.sender) {}
    
    /**
     * @dev Функція для додавання контракту голосування
     * @param _contractAddress Адреса контракту голосування
     */
    function addVotingContract(address _contractAddress) external {
        require(_contractAddress != address(0), "Invalid address");
        require(votingContracts[_contractAddress].contractAddress == address(0), "Contract already exists");
        
        votingContracts[_contractAddress] = VotingContractInfo({
            contractAddress: _contractAddress,
            owner: msg.sender,
            isActive: true
        });
        
        votingContractAddresses.push(_contractAddress);
        
        emit VotingContractAdded(_contractAddress, msg.sender);
    }
    
    /**
     * @dev Функція для видалення контракту голосування
     * @param _contractAddress Адреса контракту голосування
     */
    function removeVotingContract(address _contractAddress) external {
        require(votingContracts[_contractAddress].contractAddress != address(0), "Contract does not exist");
        require(
            votingContracts[_contractAddress].owner == msg.sender || msg.sender == owner(),
            "Not authorized"
        );
        
        votingContracts[_contractAddress].isActive = false;
        
        emit VotingContractRemoved(_contractAddress);
    }
    
    /**
     * @dev Функція для додавання голосування
     * @param _contractAddress Адреса контракту голосування
     * @param _votingId ID голосування в контракті
     * @return ID голосування в реєстрі
     */
    function addVoting(address _contractAddress, uint256 _votingId) external returns (uint256) {
        require(votingContracts[_contractAddress].contractAddress != address(0), "Contract does not exist");
        require(votingContracts[_contractAddress].isActive, "Contract is not active");
        require(
            votingContracts[_contractAddress].owner == msg.sender || msg.sender == _contractAddress,
            "Not authorized"
        );
        
        uint256 votingId = votingsCount;
        
        votings[votingId] = VotingInfo({
            contractAddress: _contractAddress,
            votingId: _votingId,
            isActive: true
        });
        
        contractVotings[_contractAddress].push(votingId);
        
        votingsCount++;
        
        emit VotingAdded(votingId, _contractAddress, _votingId);
        
        return votingId;
    }
    
    /**
     * @dev Функція для видалення голосування
     * @param _votingId ID голосування в реєстрі
     */
    function removeVoting(uint256 _votingId) external {
        require(_votingId < votingsCount, "Voting does not exist");
        require(votings[_votingId].isActive, "Voting is not active");
        
        address contractAddress = votings[_votingId].contractAddress;
        
        require(
            votingContracts[contractAddress].owner == msg.sender || msg.sender == owner(),
            "Not authorized"
        );
        
        votings[_votingId].isActive = false;
        
        emit VotingRemoved(_votingId);
    }
    
    /**
     * @dev Функція для отримання списку голосувань контракту
     * @param _contractAddress Адреса контракту голосування
     * @return Масив ID голосувань
     */
    function getContractVotings(address _contractAddress) external view returns (uint256[] memory) {
        return contractVotings[_contractAddress];
    }
    
    /**
     * @dev Функція для отримання кількості контрактів голосування
     * @return Кількість контрактів голосування
     */
    function getVotingContractsCount() external view returns (uint256) {
        return votingContractAddresses.length;
    }
    
    /**
     * @dev Функція для перевірки, чи є контракт активним
     * @param _contractAddress Адреса контракту голосування
     * @return true, якщо контракт активний
     */
    function isContractActive(address _contractAddress) external view returns (bool) {
        return votingContracts[_contractAddress].isActive;
    }
    
    /**
     * @dev Функція для перевірки, чи є голосування активним
     * @param _votingId ID голосування в реєстрі
     * @return true, якщо голосування активне
     */
    function isVotingActive(uint256 _votingId) external view returns (bool) {
        return votings[_votingId].isActive;
    }
    
    /**
     * @dev Функція для отримання адреси контракту голосування за ID голосування
     * @param _votingId ID голосування в реєстрі
     * @return Адреса контракту голосування
     */
    function getVotingContract(uint256 _votingId) external view returns (address) {
        require(_votingId < votingsCount, "Voting does not exist");
        return votings[_votingId].contractAddress;
    }
    
    /**
     * @dev Функція для отримання ID голосування в контракті
     * @param _votingId ID голосування в реєстрі
     * @return ID голосування в контракті
     */
    function getVotingIdInContract(uint256 _votingId) external view returns (uint256) {
        require(_votingId < votingsCount, "Voting does not exist");
        return votings[_votingId].votingId;
    }
}