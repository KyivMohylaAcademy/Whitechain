// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Marketplace
 * @dev Реалізація маркетплейсу для купівлі та продажу токенів ERC20
 * @author Ваше ім'я
 */
contract Marketplace is Ownable {
    // Структура для зберігання інформації про продаж токенів
    struct Sale {
        address seller;
        uint256 amount;
        uint256 price;
        bool isActive;
    }
    
    // Маппінг для зберігання всіх продажів
    mapping(uint256 => Sale) public sales;
    uint256 public salesCount;
    
    // Адреса токена ERC20
    address public tokenAddress;
    
    // Вартість токенів в коїнах
    uint256 public tokenPrice;
    
    // Події
    event TokenBought(address indexed buyer, uint256 amount);
    event TokenSold(address indexed seller, uint256 amount, uint256 price);
    event SaleCreated(uint256 indexed saleId, address indexed seller, uint256 amount, uint256 price);
    event SaleCancelled(uint256 indexed saleId);
    event SalePurchased(uint256 indexed saleId, address indexed buyer);
    
    /**
     * @dev Конструктор
     * @param _tokenAddress Адреса токена ERC20
     * @param _tokenPrice Вартість токенів в коїнах
     */
    constructor(address _tokenAddress, uint256 _tokenPrice) Ownable(msg.sender) {
        tokenAddress = _tokenAddress;
        tokenPrice = _tokenPrice;
    }
    
    /**
     * @dev Функція для купівлі токенів
     * @param _amount Кількість токенів для купівлі
     */
    function buyTokens(uint256 _amount) external payable {
        require(_amount > 0, "Amount must be greater than 0");
        require(msg.value >= _amount * tokenPrice, "Insufficient payment");
        
        // Створити токени для покупця
        IERC20VotingToken(tokenAddress).mint(msg.sender, _amount);
        
        emit TokenBought(msg.sender, _amount);
    }
    
    /**
     * @dev Функція для створення продажу токенів
     * @param _amount Кількість токенів для продажу
     * @param _price Ціна за токен
     * @return ID продажу
     */
    function createSale(uint256 _amount, uint256 _price) external returns (uint256) {
        require(_amount > 0, "Amount must be greater than 0");
        require(_price > 0, "Price must be greater than 0");
        
        // Перевірка наявності достатньої кількості токенів
        require(IERC20(tokenAddress).balanceOf(msg.sender) >= _amount, "Insufficient token balance");
        
        // Перевірка дозволу на переказ токенів
        require(
            IERC20(tokenAddress).allowance(msg.sender, address(this)) >= _amount,
            "Insufficient allowance"
        );
        
        // Переказ токенів на контракт
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), _amount);
        
        uint256 saleId = salesCount;
        
        // Створення нового продажу
        sales[saleId] = Sale({
            seller: msg.sender,
            amount: _amount,
            price: _price,
            isActive: true
        });
        
        salesCount++;
        
        emit SaleCreated(saleId, msg.sender, _amount, _price);
        
        return saleId;
    }
    
    /**
     * @dev Функція для скасування продажу
     * @param _saleId ID продажу
     */
    function cancelSale(uint256 _saleId) external {
        require(_saleId < salesCount, "Sale does not exist");
        require(sales[_saleId].isActive, "Sale is not active");
        require(sales[_saleId].seller == msg.sender, "Not the seller");
        
        sales[_saleId].isActive = false;
        
        // Повернення токенів продавцю
        IERC20(tokenAddress).transfer(msg.sender, sales[_saleId].amount);
        
        emit SaleCancelled(_saleId);
    }
    
    /**
     * @dev Функція для покупки токенів з продажу
     * @param _saleId ID продажу
     */
    function purchaseSale(uint256 _saleId) external payable {
        require(_saleId < salesCount, "Sale does not exist");
        require(sales[_saleId].isActive, "Sale is not active");
        require(msg.value >= sales[_saleId].amount * sales[_saleId].price, "Insufficient payment");
        
        Sale memory sale = sales[_saleId];
        sales[_saleId].isActive = false;
        
        // Переказ токенів покупцю
        IERC20(tokenAddress).transfer(msg.sender, sale.amount);
        
        // Переказ коштів продавцю
        payable(sale.seller).transfer(sale.amount * sale.price);
        
        emit SalePurchased(_saleId, msg.sender);
    }
    
    /**
     * @dev Функція для продажу токенів та їх знищення
     * @param _amount Кількість токенів для продажу
     */
    function sellTokens(uint256 _amount) external {
        require(_amount > 0, "Amount must be greater than 0");
        
        // Перевірка наявності достатньої кількості токенів
        require(IERC20(tokenAddress).balanceOf(msg.sender) >= _amount, "Insufficient token balance");
        
        // Перевірка дозволу на переказ токенів
        require(
            IERC20(tokenAddress).allowance(msg.sender, address(this)) >= _amount,
            "Insufficient allowance"
        );
        
        // Знищення токенів
        IERC20VotingToken(tokenAddress).burn(msg.sender, _amount);
        
        // Переказ коштів продавцю
        payable(msg.sender).transfer(_amount * tokenPrice);
        
        emit TokenSold(msg.sender, _amount, tokenPrice);
    }
    
    /**
     * @dev Функція для оновлення ціни токенів
     * @param _newPrice Нова ціна
     */
    function updateTokenPrice(uint256 _newPrice) external onlyOwner {
        require(_newPrice > 0, "Price must be greater than 0");
        tokenPrice = _newPrice;
    }
}

/**
 * @title IERC20VotingToken
 * @dev Інтерфейс для взаємодії з токеном ERC20VotingToken
 */
interface IERC20VotingToken is IERC20 {
    function mint(address _to, uint256 _amount) external;
    function burn(address _from, uint256 _amount) external;
}