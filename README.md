# Solidity whitechain homework

## Deployed contract addresses
- ResourceNFT1155 - [0x9caad6eFcf9c7A09B94c5cDD480A6F22bc04e918](https://testnet.whitechain.io/address/0x9caad6eFcf9c7A09B94c5cDD480A6F22bc04e918)
- ItemNFT721 - [0x656E515135a34880CFb3C5eA44ECdB19155CDB49](https://testnet.whitechain.io/address/0x656E515135a34880CFb3C5eA44ECdB19155CDB49)
- MagicToken - [0xEE9B0ac0b8368c043aEc6D244C5aC1Bd64aff866](https://testnet.whitechain.io/address/0xEE9B0ac0b8368c043aEc6D244C5aC1Bd64aff866)
- CraftingSearch - [0x642484d87B49Bee57bE0CC89fA4E6B6e869Da22e](https://testnet.whitechain.io/address/0x642484d87B49Bee57bE0CC89fA4E6B6e869Da22e)
- Marketplace - [0x117EC1227Bad0eB37C8A2C15b51695F5A5D0CCc4](https://testnet.whitechain.io/address/0x117EC1227Bad0eB37C8A2C15b51695F5A5D0CCc4)

## How to deploy
1. Add rpc url and private key to .env file
2. Source .env file:
```sh
source .env
```

3. Run command to deploy:
```sh
forge script script/Deploy.s.sol:Deploy --rpc-url $WHITECHAIN_RPC_URL --broadcast --legacy
```

4. Get json input for verification:
```sh
forge verify-contract --chain 2625 --show-standard-json-input <contract-address> <path-to-contract-sorce-code>
```

## Test coverage
Check test coverage with command:
```sh
forge coverage
```

Results:
```
Ran 6 test suites in 9.00ms (22.97ms CPU time): 25 tests passed, 0 failed, 0 skipped (25 total tests)

╭-------------------------+-------------------+-------------------+-----------------+-----------------╮
| File                    | % Lines           | % Statements      | % Branches      | % Funcs         |
+=====================================================================================================+
| script/Deploy.s.sol     | 100.00% (21/21)   | 100.00% (27/27)   | 100.00% (0/0)   | 100.00% (1/1)   |
|-------------------------+-------------------+-------------------+-----------------+-----------------|
| src/CraftingSearch.sol  | 100.00% (42/42)   | 100.00% (48/48)   | 100.00% (10/10) | 100.00% (4/4)   |
|-------------------------+-------------------+-------------------+-----------------+-----------------|
| src/ItemNFT721.sol      | 100.00% (12/12)   | 100.00% (9/9)     | 100.00% (0/0)   | 100.00% (4/4)   |
|-------------------------+-------------------+-------------------+-----------------+-----------------|
| src/MagicToken.sol      | 100.00% (8/8)     | 100.00% (6/6)     | 100.00% (1/1)   | 100.00% (3/3)   |
|-------------------------+-------------------+-------------------+-----------------+-----------------|
| src/Marketplace.sol     | 100.00% (23/23)   | 100.00% (29/29)   | 100.00% (8/8)   | 100.00% (4/4)   |
|-------------------------+-------------------+-------------------+-----------------+-----------------|
| src/ResourceNFT1155.sol | 100.00% (17/17)   | 100.00% (13/13)   | 100.00% (0/0)   | 100.00% (7/7)   |
|-------------------------+-------------------+-------------------+-----------------+-----------------|
| Total                   | 100.00% (123/123) | 100.00% (132/132) | 100.00% (19/19) | 100.00% (23/23) |
╰-------------------------+-------------------+-------------------+-----------------+-----------------╯
```

## Funcionality
1. Game has 6 resources: Wood, Iron, Gold, Leather, Stone, Diamond.
2. It allows to search for these resources with a 60 second cooldown and grants 3 random drops per search.
3. Resource contract supports the ERC1155 standard with role-gated minting and burning.
4. Item contract supports the ERC721 standard, minting Saber, Staff, Armor, and Bracelet NFTs via controlled roles.
5. Magic token contract supports the ERC20 standard with marketplace-restricted mint and burn helpers.
6. Marketplace trades burn purchased items while recycling Magic tokens between buyer and seller.
