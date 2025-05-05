# Козацький Бізнес - Blockchain NFT Game

Блокчейн-гра з NFT механіками, розроблена на платформі Ethereum. Гра дозволяє гравцям шукати ресурси, крафтити предмети та торгувати ними на маркетплейсі.

## Адреси контрактів (мережа Sepolia)

| Контракт | Адреса | Etherscan |
|----------|--------|-----------|
| ResourceNFT1155 | 0x30Fba0b7aAaEd0A49e486165Db75e908817b0B0D | [Переглянути](https://sepolia.etherscan.io/address/0x30Fba0b7aAaEd0A49e486165Db75e908817b0B0D#code) |
| ItemNFT721 | 0xc022fd5D8D0B34d86289E660269a2EBCFD1B5781 | [Переглянути](https://sepolia.etherscan.io/address/0xc022fd5D8D0B34d86289E660269a2EBCFD1B5781#code) |
| MagicToken | 0x223c1d0df523771D8125197617318f97Dd913C51 | [Переглянути](https://sepolia.etherscan.io/address/0x223c1d0df523771D8125197617318f97Dd913C51#code) |
| GameMechanics | 0x9E5f008f03efbCF42E7844aba7DB54Bd2998Da8B | [Переглянути](https://sepolia.etherscan.io/address/0x9E5f008f03efbCF42E7844aba7DB54Bd2998Da8B#code) |
| Marketplace | 0x499b2f76E073aAF4199B72A868992a3e29f79096 | [Переглянути](https://sepolia.etherscan.io/address/0x499b2f76E073aAF4199B72A868992a3e29f79096#code) |

## Встановлення та запуск

```bash
# Клонування репозиторію
git clone https://github.com/Kkrykunov/kozak-business-game.git
cd kozak-business-game

# Встановлення залежностей
npm install

# Компіляція контрактів
npm run compile

# Запуск тестів
npm run test

# Деплой контрактів (потрібен .env файл з налаштуваннями)
npm run deploy:sepolia
```

## Основні функції

### Пошук ресурсів
- Гравці можуть шукати ресурси раз на хвилину
- Кожен пошук дає 3 випадкових ресурси
- Ресурси представлені як ERC-1155 токени

### Крафтинг предметів
- Гравці можуть створювати предмети з ресурсів
- Кожен предмет має свій унікальний рецепт
- Предмети представлені як ERC-721 токени

### Маркетплейс
- Гравці можуть продавати та купувати ресурси і предмети
- Валюта для торгівлі - Magic Token (ERC-20)
- Комісія маркетплейсу - 2%

## Технології
- Solidity 0.8.24
- Hardhat
- Ethers.js
- OpenZeppelin Contracts 5.0

## Ліцензія
Проект розповсюджується під ліцензією MIT.

## Автор
Зигмунд Крикунов