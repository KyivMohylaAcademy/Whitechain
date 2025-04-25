# Voting Contracts

This application is created as a part of submission of Whitebit's task in NaUKMA Blockchain course.

It implements smart contracts for simple voting mechanism.

The mechanism chosen for this submission uses **minimum amount of ERC20 tokens to be available to vote** as a criteria.

## Smart contracts

### Personal contracts 

- `ERC20VotingToken` - Token which is used for allowing users to vote on `VotingContract`
- `ERC20VotingTokenMarketplace` - Marketplace that can be used to buy/sell `ERC20VotingToken`. The price is fixed, tokens are minted/burned at the moment of buy/sell
- `VotingContract` - Contract which performs votings themselves. Only 1 voting can be active at a time

### Registry

- `VotingRegistry` - registry contract for all voting contracts

## Assumptions made during development:

### `ERC20VotingToken` / `ERC20VotingTokenMarketplace`

- Tokens are minted/burned at the moment of buy/sell
- Price is fixed

### `VotingContract`

- Any voting can have votings count limited by 8-bit unsigned integer
- Any voting consists of: title, description
- Any voting variant consists of: title

### `VotingRegistry`

- Any single voting is represented by an id (just like tokens in ERC1151)
- Removing a voting for a voting contract should keep the voting array's order
- Voting contract should handle state of voting (in progress, ended, etc.)

## Deployment

### Deployed contract addresses

#### Sepolia testnet

- `VotingRegistry` - `0xaF94c252Ac8C2dABbe7D637af75EcEFb927bBFD8`
- `ERC20VotingToken` - `0xdA458cA8269Af986063AA3FC994Dbb2EbA2426C2`
- `ERC20VotingTokenMarketplace` - `0x77c1e3BFc1d0E20223783dc20787Ed62E32C631B`
- `VotingContract` - `0xC7049338508ae516743F3Fa9bEE5b0F6227d3bac`

#### Whitechain testnet

- `VotingRegistry` - `0x77c1e3BFc1d0E20223783dc20787Ed62E32C631B`
- `ERC20VotingToken` - `0xdA458cA8269Af986063AA3FC994Dbb2EbA2426C2`
- `ERC20VotingTokenMarketplace` - `0xC7049338508ae516743F3Fa9bEE5b0F6227d3bac`
- `VotingContract` - `0x5478d0675DE6A01c2194968219B9468148dDbC39`

### Deployment instructions

Hardhat ignition is used for deployments

#### Pre-requisites

- For sepolia testnet deployment, set up `SEPOLIA_PRIVATE_KEY` and `INFURA_API_KEY` using `pnpm hardhat vars set`
- For whitechain testnet deployment, set up `WHITECHAIN_TESTNET_PRIVATE_KEY` using `pnpm hardhat vars set`

#### `VotingRegistry`

You can deploy `VotingRegistry` contract using npm script

- Sepolia testnet - `deploy:registry:sepolia`
- Whitechain testnet - `deploy:registry:whitenet-testnet`

#### Other voting contracts

You can deploy other voting contracts using npm script

- Sepolia testnet - `deploy:voting:sepolia`
- Whitechain testnet - `deploy:voting:whitenet-testnet`