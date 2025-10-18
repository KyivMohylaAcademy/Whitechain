// SPDX-License-Identifier: MIT
pragma solidity =0.8.30;

import "./ResourceNFT1155.sol";
import "./ItemNFT721.sol";

/// @title CraftingSearch
/// @notice Контракт для пошуку ресурсів та крафту предметів
/// @dev Використовує псевдовипадкову генерацію для ресурсів
contract CraftingSearch {
    ResourceNFT1155 public immutable resourceNFT;
    ItemNFT721 public immutable itemNFT;

    /// @notice Час між пошуками (60 секунд)
    uint256 public constant SEARCH_COOLDOWN = 60;

    /// @notice Останній час пошуку для кожного гравця
    mapping(address => uint256) public lastSearchTime;

    /// @notice Рецепти для крафту
    struct Recipe {
        uint256[] resourceIds;
        uint256[] amounts;
        ItemNFT721.ItemType itemType;
        bool enabled;
    }

    /// @notice Мапа рецептів
    mapping(ItemNFT721.ItemType => Recipe) public recipes;

    /// @notice Подія пошуку ресурсів
    /// @param player Адреса гравця
    /// @param resourceIds ID знайдених ресурсів
    /// @param amounts Кількість кожного ресурсу
    event ResourcesFound(address indexed player, uint256[] resourceIds, uint256[] amounts);

    /// @notice Подія крафту предмета
    /// @param player Адреса гравця
    /// @param tokenId ID створеного предмета
    /// @param itemType Тип предмета
    event ItemCrafted(address indexed player, uint256 indexed tokenId, ItemNFT721.ItemType itemType);

    /// @notice Конструктор контракту
    /// @param resourceNFT_ Адреса контракту ресурсів
    /// @param itemNFT_ Адреса контракту предметів
    constructor(address resourceNFT_, address itemNFT_) {
        require(resourceNFT_ != address(0), "Invalid resource NFT address");
        require(itemNFT_ != address(0), "Invalid item NFT address");

        resourceNFT = ResourceNFT1155(resourceNFT_);
        itemNFT = ItemNFT721(itemNFT_);

        _initializeRecipes();
    }

    /// @notice Ініціалізація рецептів
    function _initializeRecipes() private {
        // Константи ресурсів
        uint256 WOOD = 0;
        uint256 IRON = 1;
        uint256 GOLD = 2;
        uint256 LEATHER = 3;
        // uint256 STONE = 4; // Не використовується в рецептах
        uint256 DIAMOND = 5;

        // Шабля козака: 3 Залізо, 1 Дерево, 1 Шкіра
        uint256[] memory saberRes = new uint256[](3);
        saberRes[0] = IRON;
        saberRes[1] = WOOD;
        saberRes[2] = LEATHER;
        
        uint256[] memory saberAmt = new uint256[](3);
        saberAmt[0] = 3;
        saberAmt[1] = 1;
        saberAmt[2] = 1;
        
        recipes[ItemNFT721.ItemType.COSSACK_SABER] = Recipe({
            resourceIds: saberRes,
            amounts: saberAmt,
            itemType: ItemNFT721.ItemType.COSSACK_SABER,
            enabled: true
        });

        // Посох старійшини: 2 Дерево, 1 Золото, 1 Алмаз
        uint256[] memory staffRes = new uint256[](3);
        staffRes[0] = WOOD;
        staffRes[1] = GOLD;
        staffRes[2] = DIAMOND;
        
        uint256[] memory staffAmt = new uint256[](3);
        staffAmt[0] = 2;
        staffAmt[1] = 1;
        staffAmt[2] = 1;
        
        recipes[ItemNFT721.ItemType.ELDER_STAFF] = Recipe({
            resourceIds: staffRes,
            amounts: staffAmt,
            itemType: ItemNFT721.ItemType.ELDER_STAFF,
            enabled: true
        });

        // Броня характерника: 4 Шкіра, 2 Залізо, 1 Золото
        uint256[] memory armorRes = new uint256[](3);
        armorRes[0] = LEATHER;
        armorRes[1] = IRON;
        armorRes[2] = GOLD;
        
        uint256[] memory armorAmt = new uint256[](3);
        armorAmt[0] = 4;
        armorAmt[1] = 2;
        armorAmt[2] = 1;
        
        recipes[ItemNFT721.ItemType.CHARACTERNYK_ARMOR] = Recipe({
            resourceIds: armorRes,
            amounts: armorAmt,
            itemType: ItemNFT721.ItemType.CHARACTERNYK_ARMOR,
            enabled: true
        });

        // Бойовий браслет: 4 Залізо, 2 Золото, 2 Алмаз
        uint256[] memory braceletRes = new uint256[](3);
        braceletRes[0] = IRON;
        braceletRes[1] = GOLD;
        braceletRes[2] = DIAMOND;
        
        uint256[] memory braceletAmt = new uint256[](3);
        braceletAmt[0] = 4;
        braceletAmt[1] = 2;
        braceletAmt[2] = 2;
        
        recipes[ItemNFT721.ItemType.BATTLE_BRACELET] = Recipe({
            resourceIds: braceletRes,
            amounts: braceletAmt,
            itemType: ItemNFT721.ItemType.BATTLE_BRACELET,
            enabled: true
        });
    }

    /// @notice Пошук ресурсів
    /// @dev Генерує 3 випадкових ресурси, доступно раз на 60 секунд
    function searchResources() external {
        require(
            block.timestamp >= lastSearchTime[msg.sender] + SEARCH_COOLDOWN,
            "Search is on cooldown"
        );

        lastSearchTime[msg.sender] = block.timestamp;

        // Генерація 3 випадкових ресурсів
        uint256[] memory resourceIds = new uint256[](3);
        uint256[] memory amounts = new uint256[](3);

        for (uint256 i = 0; i < 3; i++) {
            // Псевдовипадкова генерація
            uint256 randomResource = uint256(
                keccak256(abi.encodePacked(block.timestamp, block.prevrandao, msg.sender, i))
            ) % 6;
            
            resourceIds[i] = randomResource;
            amounts[i] = 1;

            resourceNFT.mint(msg.sender, randomResource, 1);
        }

        emit ResourcesFound(msg.sender, resourceIds, amounts);
    }

    /// @notice Крафт предмета
    /// @param itemType Тип предмета для створення
    /// @return tokenId ID створеного предмета
    function craftItem(ItemNFT721.ItemType itemType) external returns (uint256) {
        Recipe memory recipe = recipes[itemType];
        require(recipe.enabled, "Recipe not enabled");

        // Перевірка наявності ресурсів
        for (uint256 i = 0; i < recipe.resourceIds.length; i++) {
            require(
                resourceNFT.balanceOf(msg.sender, recipe.resourceIds[i]) >= recipe.amounts[i],
                "Insufficient resources"
            );
        }

        // Спалення ресурсів
        resourceNFT.burnBatch(msg.sender, recipe.resourceIds, recipe.amounts);

        // Створення предмета
        uint256 tokenId = itemNFT.mint(msg.sender, itemType);

        emit ItemCrafted(msg.sender, tokenId, itemType);
        return tokenId;
    }

    /// @notice Отримання рецепту
    /// @param itemType Тип предмета
    /// @return resourceIds ID необхідних ресурсів
    /// @return amounts Кількість кожного ресурсу
    /// @return enabled Чи активний рецепт
    function getRecipe(ItemNFT721.ItemType itemType)
        external
        view
        returns (
            uint256[] memory resourceIds,
            uint256[] memory amounts,
            bool enabled
        )
    {
        Recipe memory recipe = recipes[itemType];
        return (recipe.resourceIds, recipe.amounts, recipe.enabled);
    }

    /// @notice Перевірка доступності пошуку
    /// @param player Адреса гравця
    /// @return available Чи може гравець шукати
    /// @return timeLeft Часу залишилось до наступного пошуку
    function canSearch(address player) external view returns (bool available, uint256 timeLeft) {
        uint256 nextSearchTime = lastSearchTime[player] + SEARCH_COOLDOWN;
        
        if (block.timestamp >= nextSearchTime) {
            return (true, 0);
        } else {
            return (false, nextSearchTime - block.timestamp);
        }
    }

    /// @notice Перевірка можливості крафту
    /// @param player Адреса гравця
    /// @param itemType Тип предмета
    /// @return available Чи може гравець створити предмет
    function canCraft(address player, ItemNFT721.ItemType itemType)
        external
        view
        returns (bool available)
    {
        Recipe memory recipe = recipes[itemType];
        if (!recipe.enabled) return false;

        for (uint256 i = 0; i < recipe.resourceIds.length; i++) {
            if (resourceNFT.balanceOf(player, recipe.resourceIds[i]) < recipe.amounts[i]) {
                return false;
            }
        }

        return true;
    }
}