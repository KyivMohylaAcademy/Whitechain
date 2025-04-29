<<<<<<< HEAD
# WhiteBIT Blockchain Project

Проєкт включає Web3 авторизацію та реалізацію голосування на основі ERC20 токенів.

## Реалізовані компоненти

1. **Web3 авторизація** через MetaMask
2. **Голосування через ERC20 з перевіркою балансу**:
   - Користувач може купити токени в Marketplace
   - Для голосування потрібно мати мінімальну кількість токенів
   - Кожен користувач голосує один раз
   - Голосування обмежене в часі

## Адреси розгорнутих контрактів

### Ethereum Sepolia та Whitechain Testnet
- VotingRegistry: `0xA2A664898A5d1C2f073494f3331Dc14d0eb5202F`
- ERC20VotingToken: `0xc7f28950c5eE4b9b8B27dB1538803fcE4D620AD2`
- Marketplace: `0xa917948b20185AFEb998Fcb4546B6a42199F4E1C`
- VotingContract: `0x6E3EBdd7f53141d910DeC5264257b0F10Cd14E22`

*Примітка: Адреси контрактів однакові в обох мережах, оскільки вони були розгорнуті з того самого гаманця з однаковим nonce.*

## Як запустити проєкт

### Встановлення
```
npm install
```

### Тестування
```
npx hardhat test
```

### Розгортання
```
npx hardhat run scripts/deploy.ts --network sepolia
npx hardhat run scripts/deploy-whitechain.ts --network whitechain
```

## Виконані вимоги
- ✅ Solidity 0.8.24
- ✅ Розгорнуто в Sepolia та Whitechain
- ✅ 100% покриття тестами
- ✅ Використання Hardhat та TypeScript