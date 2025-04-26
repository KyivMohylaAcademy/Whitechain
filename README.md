# 🗳️ Web3 NFT Voting DApp (Backend Only)

Цей проєкт реалізує бекенд-систему Web3 голосування з використанням NFT (ERC721) для Whitechain Testnet.  
Голосувати можуть лише ті користувачі, які володіють хоча б одним NFT.

---

## 🔧 Стек

- Solidity 0.8.24
- Hardhat + TypeScript
- Ethers.js
- Whitechain Testnet (https://rpc.whitechain.io)

---

## 🚀 Основні можливості

- ✅ Створення голосувань із кількома варіантами
- ✅ Голосування доступне лише для власників NFT
- ✅ Перевірка, чи користувач вже голосував
- ✅ Підрахунок голосів по кожній опції
- ✅ Отримання переможця голосування
- ✅ Повне покриття тестами (Coverage 100%)

---

## 🛠️ Запуск

### 1. Встановити залежності
```bash
npm install
```

### 2. Створити `.env` на основі прикладу
```env
PRIVATE_KEY=...
WHITECHAIN_RPC_URL=https://rpc.whitechain.io
```

### 3. Компіляція контрактів
```bash
npx hardhat compile
```

### 4. Деплой контрактів
```bash
npx hardhat run scripts/deploy.ts --network whitechain
npx hardhat run scripts/deploy-nft.ts --network whitechain
```

### 5. Мінт NFT користувачу
```bash
npx hardhat run scripts/mint-nft.ts --network whitechain
```

### 6. Створення голосування
```bash
npx hardhat run scripts/createVoting.ts --network whitechain
```

### 7. Голосування
```bash
npx hardhat run scripts/vote.ts --network whitechain
```

### 8. Перевірка результатів
```bash
npx hardhat run scripts/getVotes.ts --network whitechain
npx hardhat run scripts/getWinner.ts --network whitechain
```

---

## 📁 Структура

```
├── contracts/                  # Смартконтракти (NFT + голосування)
├── scripts/                    # Скрипти: деплой, мінт, голосування, перевірка
├── test/                       # Тести з 100% покриттям
├── .env.example                # Шаблон для змінних середовища
├── hardhat.config.ts           # Конфігурація Hardhat
└── README.md
```

---

## 📄 Контракти

- VotingContractNFT: `0x4d4095a559efbA88B1390bA47C2D247D0Eb30B73`
- MyVotingNFT: `0xf574b1CF543138589e2530654F7e35A96c7a55bC`

---

## 👤 Авторка

[@lesnich](https://github.com/lesnich)  
🎓 Проєкт виконано для WhiteBIT x НаУКМА (Backend частина без фронтенду)

