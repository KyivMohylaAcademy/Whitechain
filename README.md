# Addresses of my deployed to Testnet Sepolia contracts

- **ERC20VotingToken**: `0x5927A9ee0949d1a9ccb0C43Ebe3c8E50B76119D0`
- **VotingContractERC20**: `0xd6e981C307D017EAAf7b6a7E90dF8ECbd53122e8`
- **Marketplace**: `0x336D665EF7C180B05373fa3b5D68eaa60225eE70`

---

# 1. Web3 Authorization Implementation

## Overview
A simple Web3 wallet login page that allows users to connect via MetaMask (or any Web3-compatible wallet) and interact with deployed smart contracts.

## Features:
- **Web3 Wallet Connection:** Users can connect using MetaMask or other Web3 wallets.
- **Token Purchase:** Users can buy ERC20 tokens using ETH via the Marketplace contract.
- **View Proposals:** Users can fetch and view active proposals from VotingContractERC20.
- **Vote:** Users can cast their vote for a proposal if they meet the minimum token balance requirement.
- **Error Handling:** Proper errors are shown if the connection fails or if voting requirements are not met.

## Files:
- **index.html:** Basic frontend with buttons for connecting, buying tokens, viewing proposals, and voting.
- **main.js:** Handles Web3 interactions with the contracts via Ethers.js (loaded through CDN).

## Instructions:
1. **Connect Wallet:**
    - Open `index.html` in a browser with MetaMask installed.
    - Click "Sign in with Web3" to connect your wallet.

2. **Buy Tokens:**
    - Input the amount of ETH.
    - Click "Buy" to purchase VOTE tokens.

3. **View Proposals:**
    - Proposals will be automatically fetched and displayed once connected.

4. **Vote:**
    - Input the proposal index you want to vote for.
    - Click "Vote".

## Requirements:
- MetaMask installed.

## Technologies Used:
- HTML
- JavaScript
- Ethers.js (via jsDelivr CDN)

---

# 2. Voting Implementation - Voting through ERC20 Tokens (1 vote = 1 account)

### ERC20 Voting System
- Players can purchase ERC20 tokens via the Marketplace contract using ETH.
- To participate in voting, a player must hold at least 2 tokens.
- Each player can vote **only once** per voting session, regardless of their token balance beyond the threshold.
- The proposal with the highest number of votes wins.
- Voting is time-limited (specified at the time of contract deployment).

### Contracts
- **ERC20VotingToken (ERC20):** Token used for voting; mintable and burnable only by Marketplace.
- **Marketplace:** Allows users to buy VOTE tokens with ETH and sell them back.
- **VotingContractERC20:** Main voting contract enforcing minimum token balance, single voting, and tracking winning proposals.

---

## Testing

```bash
npx hardhat test
npx hardhat test --parallel
npx hardhat coverage
$env:REPORT_GAS="true"; npx hardhat test
```

---

All code is compatible with Solidity `0.8.24` and fully tested on Sepolia Testnet.  

---
