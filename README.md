# Results

## Contract addresses
Resource contract - ```0xf74282E8ff92Ca707E2CE4a61Efc94De8bcBdac8```
Items contract - ```0x03628E913dfA97B57c5175d592bB085cF0C447a1```
Magic coins contract - ```0x8a2f4bFaC07aEdF3188213e82Bc373B53B78B96c```
Item crafting contract - ```0xc677D087C3686d2bB0BbD9Da74Ba90035C3cDDE2```
Marketplace contract - ```0x2358aBdFB3DB90f6D49C638320514215e00537d3```
Resource search contract - ```0x7CC43CE10D575AF279058233e63BFD0A3C9495D7```

## How to deploy
1. Create .env file and put there INITIAL_OWNER={YOUR_ADDRESS}
2. Enter `forge script --legacy --chain 2625 script/DeployScript.sol:DeployScript --rpc-url https://rpc-testnet.whitechain.io --broadcast --verify -vvvv --interactives 1` to deploy into white chain testnet (you can remove --rpc-url in order to test).
3. Interactive shell will ask for private key of the wallet which initiates and pays for deployment. Provide it.

## Test coverage
```
╭-------------------------+------------------+------------------+-----------------+----------------╮
| File                    | % Lines          | % Statements     | % Branches      | % Funcs        |
+==================================================================================================+
| src/Item.sol            | 100.00% (16/16)  | 100.00% (10/10)  | 100.00% (4/4)   | 100.00% (6/6)  |
|-------------------------+------------------+------------------+-----------------+----------------|
| src/ItemCrafting.sol    | 100.00% (51/51)  | 100.00% (56/56)  | 100.00% (6/6)   | 100.00% (3/3)  |
|-------------------------+------------------+------------------+-----------------+----------------|
| src/MagicCoins.sol      | 100.00% (8/8)    | 100.00% (5/5)    | 100.00% (4/4)   | 100.00% (3/3)  |
|-------------------------+------------------+------------------+-----------------+----------------|
| src/Marketplace.sol     | 100.00% (22/22)  | 100.00% (19/19)  | 100.00% (8/8)   | 100.00% (4/4)  |
|-------------------------+------------------+------------------+-----------------+----------------|
| src/Resource.sol        | 100.00% (10/10)  | 100.00% (6/6)    | 100.00% (4/4)   | 100.00% (4/4)  |
|-------------------------+------------------+------------------+-----------------+----------------|
| src/ResourceSearch.sol  | 100.00% (21/21)  | 100.00% (23/23)  | 100.00% (2/2)   | 100.00% (4/4)  |
|-------------------------+------------------+------------------+-----------------+----------------|
| Total                   | 100.00% (128/128)| 100.00% (119/119)| 100.00% (28/28) | 92.31% (24/26) |
╰-------------------------+------------------+------------------+-----------------+----------------╯
```

# Вимоги до коду 
1. Solidity = 0.8.24
2. Deployed and verified in whitechain TestNet
3. 100% test coverage 
4. Deploy must be done via Hardhat or Foundry
5. Scripts are written in typescript. Завдання: Гравці можуть об’єднувати ресурси та створювати унікальні предмети NFT721:
6. Comments format is natSpec?
7. Readme file must contain addresses of deployed contracts
8. Readme file must have instructions about how to deploy contract
9. Libs may be used, optionally.(UUPSUpgradeable Initializable AccessControl)

# Functionality
1. Kozzaks game
2. Game has 6 basic items (NFT1155): wood, iron, gold, leather, stone, dimond
3. Players may collect resources and craft items
1. Items craft: 
    Kozzak sable - 3x-iron, 1x-wood, 1x-leather
    Elders stick - 2x-wood, 1x-gold, 1x-diamond
    Armour - 4x-leather, 2x-iron, 1x-gold
    brace - 4x-iron, 2x-gold, 2x-diamond
2. Craft is available only via Crafting contract
3. Farm of resources is available only via Search contract
4. Direct creation/destruction via  NFT-1155 / NFT721 contracts is forbidden
5. Destruction is available only via "Marketplace" contract
6. Internal currency like magic tokets (ERC20) should exist.
7. Magic tokens can be obtained only via Marketplace contract selling items, direct minting is forbidden.
8. Magic tokens appear in the wallet of seller
9. Search can be run once every 60 seconds. Search generate 3 random resources (ResourceNFT1155) that appear in wallen of Player
10. To create item  (ItemNFT721) via craft, player must have enough resources.
11. During craft resources are destroyed and instead item is created via unique ID (NFT721)
12. Created items may be sold on marketplace or sent to other players.
13. Players can sell items for magic coins.
14. If item has been bought via market, magic tokens are destroed, seller receives magic tokens on his accoutn.
15. Contracts: ResourceNFT1155 ItemNFT721 (2-4)
16. magic token (ERC-20)
17. Crafting search, marketplace
