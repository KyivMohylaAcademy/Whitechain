// SPDX-License-Identifier: MIT
pragma solidity =0.8.30;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./ItemNFT721.sol";
import "./MagicToken.sol";

/// @title Marketplace
/// @notice Маркетплейс для продажу ігрових предметів за MagicToken
/// @dev При продажу предмет спалюється, а продавець отримує токени
contract Marketplace is ReentrancyGuard {
    ItemNFT721 public immutable itemNFT;
    MagicToken public immutable magicToken;

    /// @notice Структура лістингу
    struct Listing {
        address seller;
        uint256 price;
        bool active;
    }

    /// @notice Мапа токен ID -> лістинг
    mapping(uint256 => Listing) public listings;

    /// @notice Базові ціни для кожного типу предмета (в токенах з 18 десятковими)
    mapping(ItemNFT721.ItemType => uint256) public baseItemPrices;

    /// @notice Подія створення лістингу
    /// @param tokenId ID токену
    /// @param seller Адреса продавця
    /// @param price Ціна
    event ItemListed(uint256 indexed tokenId, address indexed seller, uint256 price);

    /// @notice Подія скасування лістингу
    /// @param tokenId ID токену
    event ItemUnlisted(uint256 indexed tokenId);

    /// @notice Подія покупки предмета
    /// @param tokenId ID токену
    /// @param buyer Адреса покупця
    /// @param seller Адреса продавця
    /// @param price Ціна покупки
    event ItemSold(uint256 indexed tokenId, address indexed buyer, address indexed seller, uint256 price);

    /// @notice Конструктор контракту
    /// @param itemNFT_ Адреса контракту предметів
    /// @param magicToken_ Адреса контракту токенів
    constructor(address itemNFT_, address magicToken_) {
        require(itemNFT_ != address(0), "Invalid item NFT address");
        require(magicToken_ != address(0), "Invalid magic token address");

        itemNFT = ItemNFT721(itemNFT_);
        magicToken = MagicToken(magicToken_);

        // Встановлення базових цін
        baseItemPrices[ItemNFT721.ItemType.COSSACK_SABER] = 100 ether;
        baseItemPrices[ItemNFT721.ItemType.ELDER_STAFF] = 200 ether;
        baseItemPrices[ItemNFT721.ItemType.CHARACTERNYK_ARMOR] = 300 ether;
        baseItemPrices[ItemNFT721.ItemType.BATTLE_BRACELET] = 400 ether;
    }

    /// @notice Виставлення предмета на продаж
    /// @param tokenId ID токену
    /// @param price Ціна в MagicToken
    function listItem(uint256 tokenId, uint256 price) external {
        require(itemNFT.ownerOf(tokenId) == msg.sender, "Not token owner");
        require(price > 0, "Price must be greater than 0");
        require(!listings[tokenId].active, "Item already listed");
        require(
            itemNFT.getApproved(tokenId) == address(this) ||
            itemNFT.isApprovedForAll(msg.sender, address(this)),
            "Marketplace not approved"
        );

        listings[tokenId] = Listing({
            seller: msg.sender,
            price: price,
            active: true
        });

        emit ItemListed(tokenId, msg.sender, price);
    }

    /// @notice Зняття предмета з продажу
    /// @param tokenId ID токену
    function unlistItem(uint256 tokenId) external {
        Listing storage listing = listings[tokenId];
        require(listing.active, "Item not listed");
        require(listing.seller == msg.sender, "Not seller");

        listing.active = false;

        emit ItemUnlisted(tokenId);
    }

    /// @notice Покупка предмета
    /// @param tokenId ID токену
    function buyItem(uint256 tokenId) external nonReentrant {
        Listing storage listing = listings[tokenId];
        require(listing.active, "Item not listed");
        require(itemNFT.ownerOf(tokenId) == listing.seller, "Seller no longer owns item");
        require(msg.sender != listing.seller, "Cannot buy own item");

        uint256 price = listing.price;
        address seller = listing.seller;

        // Деактивація лістингу
        listing.active = false;

        // Спалення предмета
        itemNFT.burn(tokenId);

        // Мінт токенів продавцю
        magicToken.mint(seller, price);

        emit ItemSold(tokenId, msg.sender, seller, price);
    }

    /// @notice Отримання інформації про лістинг
    /// @param tokenId ID токену
    /// @return seller Адреса продавця
    /// @return price Ціна
    /// @return active Чи активний лістинг
    function getListing(uint256 tokenId)
        external
        view
        returns (
            address seller,
            uint256 price,
            bool active
        )
    {
        Listing memory listing = listings[tokenId];
        return (listing.seller, listing.price, listing.active);
    }

    /// @notice Отримання базової ціни предмета
    /// @param itemType Тип предмета
    /// @return uint256 Базова ціна
    function getBasePrice(ItemNFT721.ItemType itemType) external view returns (uint256) {
        return baseItemPrices[itemType];
    }

    /// @notice Отримання рекомендованої ціни для токену
    /// @param tokenId ID токену
    /// @return uint256 Рекомендована ціна
    function getRecommendedPrice(uint256 tokenId) external view returns (uint256) {
        require(itemNFT.exists(tokenId), "Token does not exist");
        (ItemNFT721.ItemType itemType, , ) = itemNFT.itemMetadata(tokenId);
        return baseItemPrices[itemType];
    }
}