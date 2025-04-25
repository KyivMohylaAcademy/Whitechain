# Crafting contracts

This application is created as a part of submission of Whitebit's task in NaUKMA Blockchain course.

It implements smart contracts for game-like crafting mechanism.

## Smart contracts

- `GameItemNFT721` - ERC721 token representing game items
- `MagicToken` - ERC20 token representing magic tokens
- `ResourceNFT1155` - ERC1155 token representing resources
- `GameItemsMarketplace` - Marketplace for game items
- `ResourceCrafting` - Contract for crafting resources into game items
- `ResourceSearch` - Contract for searching resources

## Assumptions made during development

- Single `GameItemNFT721` contract is used for all game items
- There is no way to purchase game items directly

## Deployment

### Deployed contract addresses

#### Sepolia testnet

- `GameItemNFT721` - `0x929BA31dAf47D57e853845508a2D467Df8dF84CD`
- `ResourceNFT1155` - `0x07449998fc57743F9d60Cd89eB18aa449ed6a405`
- `MagicToken` - `0x769801CF4ACedC5885B7F5C023Bb2Db0B86B0e41`
- `GameItemsMarketplace` - `0xf8DdF0cd399de75fE1fd315bC09cC57DC63dEa4f`
- `ResourceCrafting` - `0x9cA60196704c58404e30128eEDA3da81757FB9A4`
- `ResourceSearch` - `0x6AB88114606ff6Bd0b497925466b28694b44B437`


#### Whitechain testnet

- `GameItemNFT721` - `0x769801CF4ACedC5885B7F5C023Bb2Db0B86B0e41`
- `ResourceNFT1155` - `0xf8DdF0cd399de75fE1fd315bC09cC57DC63dEa4f`
- `MagicToken` - `0x07449998fc57743F9d60Cd89eB18aa449ed6a405`
- `GameItemsMarketplace` - `0x9cA60196704c58404e30128eEDA3da81757FB9A4`
- `ResourceCrafting` - `0x6AB88114606ff6Bd0b497925466b28694b44B437`
- `ResourceSearch` - `0xdeD8D408FFE772a7845c2D87695545c2D6c6647b`

### Deployment instructions

#### Pre-requisites

- For sepolia testnet deployment, set up `SEPOLIA_PRIVATE_KEY` and `INFURA_API_KEY` using `pnpm hardhat vars set`
- For whitechain testnet deployment, set up `WHITECHAIN_TESTNET_PRIVATE_KEY` using `pnpm hardhat vars set`

#### Deployment

You can deploy crafting contracts using npm script

- Sepolia testnet - `deploy:sepolia`
- Whitechain testnet - `deploy:whitenet-testnet`