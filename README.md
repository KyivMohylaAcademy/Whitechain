# Проєкт: Голосування через NFT

## Опис

Реалізація голосування через NFT відповідно до технічного завдання WhiteBIT для НаУКМА.

Номер 3: Кожен акаунт може придбати NFT через Marketplace та проголосувати один раз у кожному голосуванні. Незалежно від кількості NFT на акаунті, сила голосу залишається однаковою.

**Важливо:**  
Я не виконував тестування контрактів та не претендую на проходження тестового завдання.
Проєкт виконаний у спрощеній версії для демонстрації базової роботи.

---

## Мої задеплоєні контракти

```ts
export const NETWORKS = {
  sepolia: {
    name: "Sepolia Testnet",
    nftContract: "0xd3DdD872E994C89C3070cf10710E765D88E578C6",
    marketplace: "0x59795bf75d169F8d5A4a82A4043De586fd69c471",
    votingContract: "0x12E6f3B29553C18B7C68bDd0c0098784b6695ab8",
    votingRegistry: "0x649f5025a3DAd6A54bDD6999A25408DB27c7005f"
  },
  whitechain: {
    name: "Whitechain Testnet",
    nftContract: "0xd3DdD872E994C89C3070cf10710E765D88E578C6",
    marketplace: "0x59795bf75d169F8d5A4a82A4043De586fd69c471",
    votingContract: "0x12E6f3B29553C18B7C68bDd0c0098784b6695ab8",
    votingRegistry: "0x649f5025a3DAd6A54bDD6999A25408DB27c7005f"
  }
};
```

---

## Технології

- **Next.js 14** (Frontend)
- **TypeScript**
- **Ethers.js** для роботи з Web3
- **Hardhat** для розгортання контрактів
- **Solidity 0.8.24**

---

## Як запустити проєкт

1. Клонувати репозиторій

```bash
git clone github.com/cas08/Whitechain
cd whitechain-test
```

2. Встановити залежності

```bash
npm install
```

3. Створити файл `.env`

```bash
touch .env
```

І заповнити так:

```env
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_INFURA_PROJECT_ID
WHITECHAIN_RPC_URL=https://rpc-testnet.whitechain.io
PRIVATE_KEY=0xВАШ_ПРИВАТНИЙ_КЛЮЧ_ТЕСТОВОГО_АКАУНТА
```

4. Скомпілювати смарт-контракти

```bash
npx hardhat compile
```

5. Розгортання контрактів (для повторного деплою потрібно виконати послідовно):

   ### Крок 1: Спочатку деплой VotingRegistry

   ```bash
   npx hardhat run scripts/deploy-registry.js --network sepolia
   # або
   npx hardhat run scripts/deploy-registry.js --network whitechain
   ```

   ### Крок 2: Деплой основних контрактів
   
   > **Важливо:** Після отримання адреси VotingRegistry з попереднього кроку, вставте її в скрипт deploy.ts в змінну `votingRegistryAddress`

   ```bash
   npx hardhat run scripts/deploy.ts --network sepolia
   # або
   npx hardhat run scripts/deploy.ts --network whitechain
   ```

   ### Крок 3: Реєстрація VotingContract у VotingRegistry
   
   > **Важливо:** Після отримання адреси VotingContract з попереднього кроку, вставте її в скрипт register-voting-contract.js у змінну `votingContractAddress`

   ```bash
   npx hardhat run scripts/register-voting-contract.js --network sepolia
   # або
   npx hardhat run scripts/register-voting-contract.js --network whitechain
   ```
   
## Крок 4: Оновлення адрес контрактів

Після успішного деплою контрактів вам потрібно оновити адреси у файлі конфігурації для правильної роботи фронтенду:

1. Відкрийте файл `utils/contract.addresses.ts`
2. Замініть адреси контрактів на отримані під час деплою.

Заповніть адреси контрактів у відповідності до мереж, де ви їх розгорнули.
   


6. Запустити фронтенд

```bash
npm run dev
```

## Створення тестового голосування

Для створення тестового голосування використовуйте скрипт:

```bash
npx hardhat run scripts/create-voting.js --network sepolia
# або
npx hardhat run scripts/create-voting.js --network whitechain
```

Скрипт створить голосування з тривалістю 5 хвилин і опціями "Blockchain" та "AI".

Приклад відповіді:

```
Створюю тестове голосування...
Голосування успішно створено з ID: 0
Опис: Яка технологія найбільш перспективна?
Опція 1: Blockchain
Опція 2: AI
Тривалість: 5 хвилин

Деталі голосування з блокчейну:
Опис: Яка технологія найбільш перспективна?
Початок: 2025-04-26T00:17:47.000Z
Кінець: 2025-04-26T00:22:47.000Z
Опція 1: Blockchain
Опція 2: AI
Активне: true
```

---
