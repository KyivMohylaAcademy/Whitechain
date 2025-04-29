// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title ERC20VotingToken
 * @dev Реалізація токену ERC20 для винагороди учасникам голосування
 * @author Ваше ім'я
 */
contract ERC20VotingToken is ERC20, Ownable {
    // Адреса маркетплейсу
    address public marketplace;
    
    // Адреса контракту голосування
    address public votingContract;
    
    /**
     * @dev Конструктор
     * @param _name Назва токену
     * @param _symbol Символ токену
     */
    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) Ownable(msg.sender) {
    }
    
    /**
     * @dev Функція для встановлення адреси маркетплейсу
     * @param _marketplace Адреса маркетплейсу
     */
    function setMarketplace(address _marketplace) external onlyOwner {
        marketplace = _marketplace;
    }
    
    /**
     * @dev Функція для встановлення адреси контракту голосування
     * @param _votingContract Адреса контракту голосування
     */
    function setVotingContract(address _votingContract) external onlyOwner {
        votingContract = _votingContract;
    }
    
    /**
     * @dev Модифікатор для перевірки, чи є викликаючий авторизованим
     */
    modifier onlyAuthorized() {
        require(
            msg.sender == owner() || 
            msg.sender == marketplace || 
            msg.sender == votingContract,
            "Not authorized"
        );
        _;
    }
    
    /**
     * @dev Функція для створення нових токенів
     * @param _to Адреса отримувача
     * @param _amount Кількість токенів
     */
    function mint(address _to, uint256 _amount) external onlyAuthorized {
        _mint(_to, _amount);
    }
    
    /**
     * @dev Функція для знищення токенів
     * @param _from Адреса власника
     * @param _amount Кількість токенів
     */
    function burn(address _from, uint256 _amount) external onlyAuthorized {
        _burn(_from, _amount);
    }
}