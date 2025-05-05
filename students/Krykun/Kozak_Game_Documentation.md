# Козацький Бізнес - Документація

## Адреси контрактів у мережі Sepolia

| Контракт | Адреса | Etherscan |
|----------|--------|-----------|
| ResourceNFT1155 | 0x30Fba0b7aAaEd0A49e486165Db75e908817b0B0D | [Переглянути](https://sepolia.etherscan.io/address/0x30Fba0b7aAaEd0A49e486165Db75e908817b0B0D#code) |
| ItemNFT721 | 0xc022fd5D8D0B34d86289E660269a2EBCFD1B5781 | [Переглянути](https://sepolia.etherscan.io/address/0xc022fd5D8D0B34d86289E660269a2EBCFD1B5781#code) |
| MagicToken | 0x223c1d0df523771D8125197617318f97Dd913C51 | [Переглянути](https://sepolia.etherscan.io/address/0x223c1d0df523771D8125197617318f97Dd913C51#code) |
| GameMechanics | 0x9E5f008f03efbCF42E7844aba7DB54Bd2998Da8B | [Переглянути](https://sepolia.etherscan.io/address/0x9E5f008f03efbCF42E7844aba7DB54Bd2998Da8B#code) |
| Marketplace | 0x499b2f76E073aAF4199B72A868992a3e29f79096 | [Переглянути](https://sepolia.etherscan.io/address/0x499b2f76E073aAF4199B72A868992a3e29f79096#code) |

## Опис гри

Козацький Бізнес - це блокчейн-гра з NFT механіками, розроблена на платформі Ethereum. Гра дозволяє гравцям шукати ресурси, крафтити предмети та торгувати ними на маркетплейсі.

### Основні функції:

1. **Пошук ресурсів**
   - Гравці можуть шукати ресурси раз на хвилину
   - Кожен пошук дає 3 випадкових ресурси
   - Ресурси представлені як ERC-1155 токени

2. **Крафтинг предметів**
   - Гравці можуть створювати предмети з ресурсів
   - Кожен предмет має свій унікальний рецепт
   - Предмети представлені як ERC-721 токени

3. **Маркетплейс**
   - Гравці можуть продавати та купувати ресурси і предмети
   - Валюта для торгівлі - Magic Token (ERC-20)
   - Комісія маркетплейсу - 2%

### Ресурси (ResourceNFT1155):

| ID | Ресурс |
|----|--------|
| 0 | Wood (Деревина) |
| 1 | Iron (Залізо) |
| 2 | Gold (Золото) |
| 3 | Leather (Шкіра) |
| 4 | Stone (Камінь) |
| 5 | Diamond (Діамант) |

### Предмети (ItemNFT721):

| ID | Предмет | Необхідні ресурси |
|----|---------|-------------------|
| 0 | Шабля козака | 3 Iron, 1 Wood, 1 Leather |
| 1 | Посох старійшини | 2 Wood, 1 Gold, 1 Diamond |
| 2 | Броня характерника | 4 Leather, 2 Iron, 1 Gold |
| 3 | Бойовий браслет | 4 Iron, 2 Gold, 2 Diamond |

## Взаємодія з контрактами через Etherscan

### GameMechanics

1. Відкрийте [GameMechanics на Etherscan](https://sepolia.etherscan.io/address/0x9E5f008f03efbCF42E7844aba7DB54Bd2998Da8B#writeContract)
2. Підключіть MetaMask (кнопка "Connect to Web3")
3. Функції для виклику:
   - `searchResources()` - пошук ресурсів
   - `craftItem(uint8 itemType)` - крафт предмета (0-3)

### ResourceNFT1155

1. Відкрийте [ResourceNFT1155 на Etherscan](https://sepolia.etherscan.io/address/0x30Fba0b7aAaEd0A49e486165Db75e908817b0B0D#readContract)
2. Для перегляду балансу ресурсів:
   - `balanceOf(address account, uint256 id)` - введіть адресу гаманця та ID ресурсу (0-5)

### ItemNFT721

1. Відкрийте [ItemNFT721 на Etherscan](https://sepolia.etherscan.io/address/0xc022fd5D8D0B34d86289E660269a2EBCFD1B5781#readContract)
2. Для перегляду предметів:
   - `balanceOf(address owner)` - кількість предметів гравця
   - `tokenOfOwnerByIndex(address owner, uint256 index)` - ID предмета за індексом
   - `getItemType(uint256 tokenId)` - тип предмета за його ID

## Web-інтерфейс

Щоб використовувати веб-інтерфейс для гри:
1. Відкрийте файл `index.html` локально
2. Підключіть MetaMask з мережею Sepolia
3. Натисніть "Увійти через Web3"
4. Використовуйте інтерфейс для пошуку ресурсів та крафтингу предметів

## GitHub репозиторій

Репозиторій проекту доступний за посиланням: [https://github.com/Kkrykunov/kozak-business-game](https://github.com/Kkrykunov/kozak-business-game)