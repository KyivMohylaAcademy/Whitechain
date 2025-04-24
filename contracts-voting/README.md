# Assumptions made during development:

- Any single voting is represented by an id (just like tokens in ERC1151)
- Removing a voting for a voting contract should keep the voting array's order

# Deployed contract addresses

## `VotingRegistry`

For both `sepolia` and `whitenet-testnet` `VotingRegistry` are placed on same address:

```
0xaF94c252Ac8C2dABbe7D637af75EcEFb927bBFD8
```

# Deployment

Hardhat ignition is used for deployments

## Networks configuration

### `sepolia` deployment setup

1. Setup `SEPOLIA_PRIVATE_KEY` var in hardhat using `pnpm hardhat vars set SEPOLIA_PRIVATE_KEY`
2. Setup `INFURA_API_KEY` var in hardhat using `pnpmhardhat vars set INFURA_API_KEY`

### `whitenetTestnet` deployment setup

1. Setup `WHITECHAIN_TESTNET_PRIVATE_KEY` var in hardhat using `pnpm hardhat vars set WHITECHAIN_TESTNET_PRIVATE_KEY`

## `VotingRegistry`

For `sepolia` network, use `deploy:registry:sepolia` npm script using `pnpm run deploy:registry:sepolia`

For whitenet testnet network, use `deploy:registry:whitenet-testnet` npm script using `pnpm run deploy:registry:whitenet-testnet`