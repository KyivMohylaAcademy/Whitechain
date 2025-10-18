// SPDX-License-Identifier: MIT
pragma solidity =0.8.30;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/// @title ResourceNFT1155
/// @notice Контракт для управління ігровими ресурсами як NFT-1155
/// @dev Мінт та спалення доступні лише через контракти з роллю MINTER/BURNER
contract ResourceNFT1155 is ERC1155, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    /// @notice ID ресурсів
    uint256 public constant WOOD = 0;
    uint256 public constant IRON = 1;
    uint256 public constant GOLD = 2;
    uint256 public constant LEATHER = 3;
    uint256 public constant STONE = 4;
    uint256 public constant DIAMOND = 5;

    /// @notice Назви ресурсів
    mapping(uint256 => string) public resourceNames;

    /// @notice Подія створення ресурсів
    /// @param to Адреса отримувача
    /// @param id ID ресурсу
    /// @param amount Кількість
    event ResourceMinted(address indexed to, uint256 indexed id, uint256 amount);

    /// @notice Подія спалення ресурсів
    /// @param from Адреса власника
    /// @param id ID ресурсу
    /// @param amount Кількість
    event ResourceBurned(address indexed from, uint256 indexed id, uint256 amount);

    /// @notice Конструктор контракту
    /// @param uri_ Базовий URI для метаданих
    constructor(string memory uri_) ERC1155(uri_) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);

        resourceNames[WOOD] = "Wood";
        resourceNames[IRON] = "Iron";
        resourceNames[GOLD] = "Gold";
        resourceNames[LEATHER] = "Leather";
        resourceNames[STONE] = "Stone";
        resourceNames[DIAMOND] = "Diamond";
    }

    /// @notice Створення ресурсів
    /// @dev Може викликати лише адреса з роллю MINTER_ROLE
    /// @param to Адреса отримувача
    /// @param id ID ресурсу (0-5)
    /// @param amount Кількість ресурсів
    function mint(address to, uint256 id, uint256 amount) external onlyRole(MINTER_ROLE) {
        require(id <= DIAMOND, "Invalid resource ID");
        require(amount > 0, "Amount must be greater than 0");
        
        _mint(to, id, amount, "");
        emit ResourceMinted(to, id, amount);
    }

    /// @notice Спалення ресурсів
    /// @dev Може викликати лише адреса з роллю BURNER_ROLE
    /// @param from Адреса власника
    /// @param id ID ресурсу
    /// @param amount Кількість для спалення
    function burn(address from, uint256 id, uint256 amount) external onlyRole(BURNER_ROLE) {
        require(balanceOf(from, id) >= amount, "Insufficient balance");
        
        _burn(from, id, amount);
        emit ResourceBurned(from, id, amount);
    }

    /// @notice Пакетне спалення ресурсів
    /// @dev Може викликати лише адреса з роллю BURNER_ROLE
    /// @param from Адреса власника
    /// @param ids Масив ID ресурсів
    /// @param amounts Масив кількостей
    function burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) external onlyRole(BURNER_ROLE) {
        require(ids.length == amounts.length, "Arrays length mismatch");
        
        for (uint256 i = 0; i < ids.length; i++) {
            require(balanceOf(from, ids[i]) >= amounts[i], "Insufficient balance");
        }
        
        _burnBatch(from, ids, amounts);
        
        for (uint256 i = 0; i < ids.length; i++) {
            emit ResourceBurned(from, ids[i], amounts[i]);
        }
    }

    /// @notice Перевірка підтримки інтерфейсу
    /// @param interfaceId ID інтерфейсу
    /// @return bool Чи підтримується інтерфейс
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /// @notice Отримання назви ресурсу
    /// @param id ID ресурсу
    /// @return string Назва ресурсу
    function getResourceName(uint256 id) external view returns (string memory) {
        require(id <= DIAMOND, "Invalid resource ID");
        return resourceNames[id];
    }
}