# Login with Web3

This project allows users to connect their Web3 wallet (like MetaMask) to a Vue 3 application using `@wagmi/core`, `viem`, tailwind and basic CSS styling.

---

## 📋 Features

- Connect to Web3 wallets (MetaMask, etc.)
- Show connected wallet address
- Disconnect from wallet
- Styled with pure CSS (no Tailwind inside components)

---

## 🛠️ Project Setup

### 1. Clone the repository

```bash
git clone https://github.com/your-username/web3-auth-vue.git
cd web3-auth-vue
```

### 2. Install dependencies

```bash
npm install
```

If you don't have Vite installed globally, you can install it:

```bash
npm install -g vite
```

### 3. Install required packages

```bash
npm install vue @wagmi/core viem
```

- `vue` — frontend framework  
- `@wagmi/core` — Web3 connection management  
- `viem` — lightweight EVM client library  

### 4. Run the development server

```bash
npm run dev
```
or

```bash
vite
```

It will start the app at:  
[http://localhost:5173/](http://localhost:5173/) (or another port if 5173 is busy)

---

## ⚙️ Project Structure

```bash
src/
│
├── config/
│   └── wagmi.ts         # Wagmi configuration for Web3 connectors
│
├── App.vue              # Main logic: connect, disconnect, show address
│
├── assets/
│   └── *.png            # Optional preview images
│
├── style.css            # Custom CSS used instead of Tailwind in components
│
├── main.ts              # Entry point for Vite + Vue
│
index.html               # HTML shell
```

---

## 🧐 Quick Overview (How It Works)

1. User clicks “Login”
2. App shows available wallet connectors (e.g., MetaMask)
3. After selecting, it connects using Wagmi
4. Wallet address is displayed
5. “Від'єднатись” button allows disconnecting any time

---

## 🛮️ Common Issues

- **`Cannot resolve @wagmi/core`**  
  ➡ Run `npm install @wagmi/core`

- **`require is not defined` in ES module scope**  
  ➡ Make sure your `postcss.config.js` uses ESM syntax or rename to `postcss.config.cjs`

- **Tailwind styles not applying inside component**  
  ➡ Tailwind is used only for layout; inside Vue components, only custom CSS is applied.

---

## 📸 Preview

<p align="center">
  <img src="./assets/login-screen.png" width="500" alt="Login Screen" />
  <br/>
  <img src="./assets/choosing-wallet-screen.png" width="500" alt="Wallet Select" />
  <br/>
  <img src="./assets/wallet-screen.png" width="500" alt="Wallet Connected" />
  <br/>
  <img src="./assets/logout-screen.png" width="500" alt="Logout" />
</p>
