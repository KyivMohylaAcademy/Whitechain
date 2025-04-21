# 🗳️ Web3 NFT Voting DApp

Цей проєкт реалізує Web3-систему голосування з використанням NFT (ERC721).  
Голосувати можуть лише ті користувачі, які володіють хоча б одним NFT.

---

## 🔧 Стек

- Solidity 0.8.24
- Hardhat + TypeScript
- MetaMask (Web3 Auth)
- Ethereum Sepolia Testnet
- Alchemy RPC
- Ethers.js

---

## 🚀 Основні можливості

- ✅ Створення голосувань із кількома варіантами
- ✅ Голосування доступне лише для власників NFT
- ✅ Перевірка, чи користувач вже голосував
- ✅ Підрахунок голосів по кожній опції
- ✅ Отримання переможця голосування

---

## 🛠️ Запуск

### 1. Встановити залежності
```bash
npm install
```

### 2. Створити `.env` на основі прикладу
```env
PRIVATE_KEY=...
SEPOLIA_RPC_URL=https://...
```

### 3. Компіляція контракту
```bash
npx hardhat compile
```

### 4. Деплой NFT контракту
```bash
npx hardhat run scripts/deploy-nft.ts --network sepolia
npx hardhat run scripts/mint-nft.ts --network sepolia
```

### 5. Деплой контракту голосування
```bash
npx hardhat run scripts/deploy.ts --network sepolia
```

### 6. Створення голосування
```bash
npx hardhat run scripts/createVoting.ts --network sepolia
```

### 7. Голосування
```bash
npx hardhat run scripts/vote.ts --network sepolia
```

### 8. Перевірка голосів та переможця
```bash
npx hardhat run scripts/getVotes.ts --network sepolia
npx hardhat run scripts/getWinner.ts --network sepolia
```

---

## 📁 Структура

```
├── contracts/                  # Смартконтракти (NFT + голосування)
├── scripts/                   # Скрипти: деплой, голосування, перевірка
├── test/                      # Тести (опціонально)
├── .env.example               # Шаблон .env
├── hardhat.config.ts          # Конфігурація Hardhat
└── README.md
```

---

## 👤 Авторка

[@lesnich](https://github.com/lesnich)  
🎓 Проєкт виконано для WhiteBIT x НаУКМА
