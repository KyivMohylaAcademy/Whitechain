# Addresses of my deployed to Testnet Whitechain contracts

- **Lock** (demo, trial one): 0xA9B8Dca39c4d4C98a7909617347F99d8316318D5
- **Auth** (addit for web3 authentication): 0x4969dD3C6c0770fB8f326149899b3E51D880082c

- **VotingRegistry**: 0xdB95A3EAC78c69ef2b0D2690988bA4EC5bE64ccB
- **NFTContract**: 0x095405dC6Ec7f0918679a6Ee8Dd8214b67c3Cf09
- **Marketplace**: 0xDC25C4C9298752a6BC9c879b065aa1a145519024
- **VotingContract**: 0xAaf46691a6bAe3702D8764c978cfAFb4957d5021


> npx hardhat run register.ts --network whitechain;
Registering VotingContract in VotingRegistry with the account: 0xBA6c754F59336e8fA00a2a2d6697191DbdD11d4E;
VotingContract 0xAaf46691a6bAe3702D8764c978cfAFb4957d5021 successfully registered in VotingRegistry.

# 1. Web3 Authorization Implementation

## Overview
This is a simple Web3 wallet authorization system using the MetaMask extension (or any compatible Web3 wallet) to authenticate users. The user can click the "Увійти через Web3" button to connect their wallet to the website and retrieve their public wallet address.

## Features:
- **Web3 Wallet Connection:** Users can connect their Web3 wallet using MetaMask (or compatible wallets).
- **Error Handling:** If no Web3 wallet is detected, an error message prompts users to install MetaMask.
- **Success Message:** Upon successful connection, the connected wallet address is displayed.
- **Responsive and Visually Enhanced:** The page is designed to be centered on the screen with a clean, modern look.

## Files:
- **index.html:** Contains the HTML structure and includes the Web3.js library from CDN.
- **CSS Styling:** Minimal CSS to center the content and improve the appearance.
- **JavaScript (Embedded in HTML):** Handles Web3 wallet connection and displays the result.

## Instructions:
1. **Connect Web3 Wallet:**
   - Click the "Увійти через Web3" button.
   - If MetaMask (or another Web3 wallet) is installed, the browser will request permission to connect and retrieve the wallet address.
   - The wallet address will be displayed on the page.

2. **Error Handling:**
   - If no Web3 wallet is detected, users are instructed to install MetaMask.
   - If there's an error connecting to the wallet, an error message is shown.

3. **Visual Design:**
   - The content is centered both horizontally and vertically.
   - The button has a green color scheme, and messages are color-coded (red for errors and green for success).

## Requirements:
- MetaMask or another Web3 wallet installed in the browser.
- Basic knowledge of Web3.js and Ethereum.

## How to Use:
- Simply open the `index.html` file in a modern web browser with Web3 support (such as Chrome with MetaMask installed).
- Click the "Увійти через Web3" button to start the wallet connection process.

## Technologies Used:
- HTML
- CSS (for styling)
- JavaScript
- Web3.js (via CDN)


# 2. Голосування з різними типами

### Голосування через NFT (1 голос = 1 аккаунт) 
+ Гравець може придбати NFT за внутрішню валюту (коїни) в контракті Marketplace. 
+ Незалежно від кількості NFT на акаунті, гравець може проголосувати лише один раз у кожному голосуванні. 
+ NFT не впливає на силу голосу. 
+ Проголосувати можна тільки якщо у гравця є хоча б одне NFT. 
+ Перемагає те рішення за яке проголосувало більше користувачів. 
+ Голосування обмежене в часі. 

### Контракти
+ VotingRegistry (Загальний для всіх студентів) 
+ VotingContract (Контракт голосування від кожного студента) 
+ NFTContract (ERC721) (створити NFT шляхом купівлі, або спалити його шляхом продажу його в Marketplace)
+ Marketplace (купити/продати NFT шляхом запиту метода, NFT спалюється/створюється під час продажу/купівлі)



# WhiteBIT Tasks Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a Hardhat Ignition module that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat ignition deploy ./ignition/modules/Lock.ts
```

## Тестування

```bash
npx hardhat test
npx hardhat test --parallel
npx hardhat coverage
$env:REPORT_GAS="true"; npx hardhat test