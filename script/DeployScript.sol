// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../src/Item.sol";
import "../src/ItemCrafting.sol";
import "../src/MagicCoins.sol";
import "../src/Marketplace.sol";
import "../src/Resource.sol";
import "../src/ResourceSearch.sol";
import {Script} from "forge-std/Script.sol";

contract DeployScript is Script {

    function setUp() public {
    }

    function run() public {
        address owner = vm.envAddress("INITIAL_OWNER");
        vm.startBroadcast();

        // deploy tokens
        Resource resourceContract = new Resource(owner);
        Item itemContract = new Item(owner);
        MagicCoins magicCoinsContract = new MagicCoins(owner);

        // deploy logic
        ItemCrafting itemCraftingContract = new ItemCrafting(address(itemContract), address(resourceContract));
        Marketplace marketplaceContract = new Marketplace(address(magicCoinsContract), address(itemContract));
        ResourceSearch resourceSearchContract = new ResourceSearch(address(resourceContract));

        // make tokens know about caller contracts
        resourceContract.setItemCraftingContract(address(itemCraftingContract));
        resourceContract.setSearchContract(address(resourceSearchContract));
        itemContract.setItemCraftingContract(address(itemCraftingContract));
        itemContract.setMarketplaceContract(address(marketplaceContract));
        magicCoinsContract.setMarketContract(address(marketplaceContract));

        vm.stopBroadcast();
    }
}