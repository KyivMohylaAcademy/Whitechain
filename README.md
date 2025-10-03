## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

- **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
- **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
- **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
- **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
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


## Magic tokens
1. ERC-20
2. Magic tokens can be obtained only via Marketplace contract selling items, direct minting is forbidden.
3. Magic tokens appear in the wallet of seller

## Resources
