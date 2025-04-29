// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

/**
 * @title VotingContract
 * @dev Реалізація голосування з винагородою у вигляді ERC20
 * @author Ваше ім'я
 */
contract VotingContract {
    // Структура для зберігання інформації про голосування
    struct Voting {
        string title;
        string description;
        uint256 startTime;
        uint256 endTime;
        uint256 rewardAmount; // Кількість токенів для винагороди
        mapping(address => bool) hasVoted;
        mapping(uint256 => uint256) optionVotes; // option ID => кількість голосів
        uint256 optionsCount;
        bool isActive;
    }

    // Мапа для зберігання всіх голосувань
    mapping(uint256 => Voting) public votings;
    uint256 public votingsCount;

    // Адреса реєстру голосувань
    address public votingRegistry;
    
    // Адреса токена винагороди
    address public rewardToken;
    
    // Адреса маркетплейсу
    address public marketplace;
    
    // Події
    event VotingCreated(uint256 indexed votingId, string title, uint256 startTime, uint256 endTime);
    event VoteCasted(uint256 indexed votingId, address indexed voter, uint256 option);
    event RewardClaimed(uint256 indexed votingId, address indexed voter, uint256 amount);
    
    /**
     * @dev Конструктор
     * @param _votingRegistry Адреса реєстру голосувань
     * @param _rewardToken Адреса токена винагороди
     * @param _marketplace Адреса маркетплейсу
     */
    constructor(address _votingRegistry, address _rewardToken, address _marketplace) {
        votingRegistry = _votingRegistry;
        rewardToken = _rewardToken;
        marketplace = _marketplace;
    }
    
    /**
     * @dev Модифікатор для перевірки, чи є викликаючий власником контракту
     */
    modifier onlyOwner() {
        require(msg.sender == marketplace || msg.sender == votingRegistry, "Not authorized");
        _;
    }
    
    /**
     * @dev Модифікатор для перевірки, чи є голосування активним
     * @param _votingId ID голосування
     */
    modifier votingExists(uint256 _votingId) {
        require(_votingId < votingsCount, "Voting does not exist");
        _;
    }
    
    /**
     * @dev Модифікатор для перевірки, чи є голосування активним
     * @param _votingId ID голосування
     */
    modifier votingActive(uint256 _votingId) {
        require(votings[_votingId].isActive, "Voting is not active");
        require(block.timestamp >= votings[_votingId].startTime, "Voting has not started yet");
        require(block.timestamp <= votings[_votingId].endTime, "Voting has ended");
        _;
    }
    
    /**
     * @dev Функція для створення нового голосування
     * @param _title Назва голосування
     * @param _description Опис голосування
     * @param _startTime Час початку голосування
     * @param _endTime Час закінчення голосування
     * @param _optionsCount Кількість варіантів для голосування
     * @param _rewardAmount Кількість токенів для винагороди
     * @return ID нового голосування
     */
    function createVoting(
        string memory _title,
        string memory _description,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _optionsCount,
        uint256 _rewardAmount
    ) external returns (uint256) {
        require(_startTime < _endTime, "Invalid time range");
        require(_optionsCount > 1, "At least 2 options required");
        
        uint256 votingId = votingsCount;
        
        Voting storage newVoting = votings[votingId];
        newVoting.title = _title;
        newVoting.description = _description;
        newVoting.startTime = _startTime;
        newVoting.endTime = _endTime;
        newVoting.optionsCount = _optionsCount;
        newVoting.rewardAmount = _rewardAmount;
        newVoting.isActive = true;
        
        votingsCount++;
        
        emit VotingCreated(votingId, _title, _startTime, _endTime);
        
        // TODO: Додати голосування до реєстру
        // IVotingRegistry(votingRegistry).addVoting(votingId);
        
        return votingId;
    }
    
    /**
     * @dev Функція для голосування
     * @param _votingId ID голосування
     * @param _option Обраний варіант
     */
    function vote(uint256 _votingId, uint256 _option) external votingExists(_votingId) votingActive(_votingId) {
        require(_option < votings[_votingId].optionsCount, "Invalid option");
        require(!votings[_votingId].hasVoted[msg.sender], "Already voted");
        
        votings[_votingId].hasVoted[msg.sender] = true;
        votings[_votingId].optionVotes[_option]++;
        
        emit VoteCasted(_votingId, msg.sender, _option);
        
        // Надати винагороду
        claimReward(_votingId);
    }
    
    /**
     * @dev Функція для отримання винагороди
     * @param _votingId ID голосування
     */
    function claimReward(uint256 _votingId) internal votingExists(_votingId) {
        require(votings[_votingId].hasVoted[msg.sender], "You have not voted");
        
        uint256 rewardAmount = votings[_votingId].rewardAmount;
        
        // TODO: Надіслати токени винагороди
        // IERC20(rewardToken).mint(msg.sender, rewardAmount);
        
        emit RewardClaimed(_votingId, msg.sender, rewardAmount);
    }
    
    /**
     * @dev Функція для отримання результатів голосування
     * @param _votingId ID голосування
     * @param _option Варіант для перевірки
     * @return Кількість голосів за вказаний варіант
     */
    function getVotesForOption(uint256 _votingId, uint256 _option) external view votingExists(_votingId) returns (uint256) {
        require(_option < votings[_votingId].optionsCount, "Invalid option");
        return votings[_votingId].optionVotes[_option];
    }
    
    /**
     * @dev Функція для перевірки, чи проголосував користувач
     * @param _votingId ID голосування
     * @param _voter Адреса користувача
     * @return true, якщо користувач проголосував
     */
    function hasVoted(uint256 _votingId, address _voter) external view votingExists(_votingId) returns (bool) {
        return votings[_votingId].hasVoted[_voter];
    }
    
    /**
     * @dev Функція для закриття голосування
     * @param _votingId ID голосування
     */
    function closeVoting(uint256 _votingId) external onlyOwner votingExists(_votingId) {
        require(votings[_votingId].isActive, "Voting is already closed");
        require(block.timestamp > votings[_votingId].endTime, "Voting has not ended yet");
        
        votings[_votingId].isActive = false;
    }
    
    /**
     * @dev Функція для отримання інформації про голосування
     * @param _votingId ID голосування
     * @return title Назва голосування
     * @return description Опис голосування
     * @return startTime Час початку голосування
     * @return endTime Час закінчення голосування
     * @return optionsCount Кількість варіантів для голосування
     * @return isActive Чи активне голосування
     */
    function getVotingInfo(uint256 _votingId) external view votingExists(_votingId) returns (
        string memory title,
        string memory description,
        uint256 startTime,
        uint256 endTime,
        uint256 optionsCount,
        bool isActive
    ) {
        Voting storage voting = votings[_votingId];
        return (
            voting.title,
            voting.description,
            voting.startTime,
            voting.endTime,
            voting.optionsCount,
            voting.isActive
        );
    }
    
    /**
     * @dev Функція для отримання переможця голосування
     * @param _votingId ID голосування
     * @return Переможець голосування
     */
    function getWinner(uint256 _votingId) external view votingExists(_votingId) returns (uint256) {
        require(!votings[_votingId].isActive || block.timestamp > votings[_votingId].endTime, "Voting is still active");
        
        uint256 maxVotes = 0;
        uint256 winningOption = 0;
        
        for (uint256 i = 0; i < votings[_votingId].optionsCount; i++) {
            uint256 votes = votings[_votingId].optionVotes[i];
            if (votes > maxVotes) {
                maxVotes = votes;
                winningOption = i;
            }
        }
        
        return winningOption;
    }
}