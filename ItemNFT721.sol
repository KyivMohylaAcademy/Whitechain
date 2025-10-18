// SPDX-License-Identifier: MIT
pragma solidity =0.8.30;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/// @title ItemNFT721
/// @notice Контракт для унікальних ігрових предметів як NFT-721
/// @dev Мінт та спалення доступні лише через контракти з роллю MINTER/BURNER
contract ItemNFT721 is ERC721, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    uint256 private _tokenIdCounter;

    /// @notice Типи предметів
    enum ItemType {
        COSSACK_SABER,      // Шабля козака
        ELDER_STAFF,        // Посох старійшини
        CHARACTERNYK_ARMOR, // Броня характерника
        BATTLE_BRACELET     // Бойовий браслет
    }

    /// @notice Метадані предмета
    struct ItemMetadata {
        ItemType itemType;
        uint256 craftedAt;
        address crafter;
    }

    /// @notice Мапа токен ID -> метадані
    mapping(uint256 => ItemMetadata) public itemMetadata;

    /// @notice Назви предметів
    mapping(ItemType => string) public itemNames;

    /// @notice Базовий URI для метаданих
    string private _baseTokenURI;

    /// @notice Подія створення предмета
    /// @param to Адреса отримувача
    /// @param tokenId ID токену
    /// @param itemType Тип предмета
    event ItemMinted(address indexed to, uint256 indexed tokenId, ItemType itemType);

    /// @notice Подія спалення предмета
    /// @param tokenId ID токену
    /// @param itemType Тип предмета
    event ItemBurned(uint256 indexed tokenId, ItemType itemType);

    /// @notice Конструктор контракту
    /// @param name_ Назва колекції
    /// @param symbol_ Символ колекції
    /// @param baseURI_ Базовий URI
    constructor(
        string memory name_,
        string memory symbol_,
        string memory baseURI_
    ) ERC721(name_, symbol_) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _baseTokenURI = baseURI_;

        itemNames[ItemType.COSSACK_SABER] = "Cossack Saber";
        itemNames[ItemType.ELDER_STAFF] = "Elder Staff";
        itemNames[ItemType.CHARACTERNYK_ARMOR] = "Characternyk Armor";
        itemNames[ItemType.BATTLE_BRACELET] = "Battle Bracelet";
    }

    /// @notice Створення предмета
    /// @dev Може викликати лише адреса з роллю MINTER_ROLE
    /// @param to Адреса отримувача
    /// @param itemType Тип предмета
    /// @return tokenId ID створеного токену
    function mint(address to, ItemType itemType) external onlyRole(MINTER_ROLE) returns (uint256) {
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;

        _safeMint(to, tokenId);

        itemMetadata[tokenId] = ItemMetadata({
            itemType: itemType,
            craftedAt: block.timestamp,
            crafter: to
        });

        emit ItemMinted(to, tokenId, itemType);
        return tokenId;
    }

    /// @notice Спалення предмета
    /// @dev Може викликати лише адреса з роллю BURNER_ROLE
    /// @param tokenId ID токену для спалення
    function burn(uint256 tokenId) external onlyRole(BURNER_ROLE) {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");
        
        ItemType itemType = itemMetadata[tokenId].itemType;
        _burn(tokenId);
        delete itemMetadata[tokenId];

        emit ItemBurned(tokenId, itemType);
    }

    /// @notice Отримання базового URI
    /// @return string Базовий URI
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    /// @notice Встановлення базового URI
    /// @dev Може викликати лише адміністратор
    /// @param baseURI_ Новий базовий URI
    function setBaseURI(string memory baseURI_) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _baseTokenURI = baseURI_;
    }

    /// @notice Перевірка підтримки інтерфейсу
    /// @param interfaceId ID інтерфейсу
    /// @return bool Чи підтримується інтерфейс
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /// @notice Отримання загальної кількості створених токенів
    /// @return uint256 Кількість токенів
    function totalSupply() external view returns (uint256) {
        return _tokenIdCounter;
    }

    /// @notice Перевірка існування токену
    /// @param tokenId ID токену
    /// @return bool Чи існує токен
    function exists(uint256 tokenId) external view returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }

    /// @notice Отримання назви предмета за типом
    /// @param itemType Тип предмета
    /// @return string Назва предмета
    function getItemName(ItemType itemType) external view returns (string memory) {
        return itemNames[itemType];
    }
}