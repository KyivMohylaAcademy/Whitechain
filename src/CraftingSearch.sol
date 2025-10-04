// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ResourceNFT1155} from "./ResourceNFT1155.sol";
import {ItemNFT721} from "./ItemNFT721.sol";

/**
 * @title CraftingSearch (Template)
 * @notice Minimal wiring only. No randomness, no recipes. You will implement logic.
 *
 * TODO:
 * - Implement `search()` with a 60s cooldown that mints 3 random resources via ResourceNFT1155.
 * - Define recipe storage and implement `craft()`:
 *   * burn resources in ResourceNFT1155
 *   * mint item in ItemNFT721
 */
contract CraftingSearch is AccessControl {
    ResourceNFT1155 public resources;
    ItemNFT721 public items;

    // Optional constant for your cooldown if you need it later
    uint256 public constant SEARCH_COOLDOWN = 60 seconds;
    uint256 public constant SEARCH_RESULT_RESOURCE_COUNT = 3;

    uint256 private nonce = 0;

    mapping (address => uint256) public addressLastSearchTime;

    constructor(address admin, ResourceNFT1155 _resources, ItemNFT721 _items) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        resources = _resources;
        items = _items;
    }

    /// @notice TODO: implement resource search (cooldown + mintBatch on ResourceNFT1155).
    function search() external {
        require(addressLastSearchTime[msg.sender] < (block.timestamp - SEARCH_COOLDOWN), "Cooldown did not ended");

        uint256[] memory foundResources = resources.getResourceIds();
        uint256[] memory foundResourcesAmounts = new uint256[](foundResources.length);

        for (uint256 i = 0; i < SEARCH_RESULT_RESOURCE_COUNT; i++) {
            uint256 foundResource = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, nonce, i))) % foundResources.length;
            nonce++;

            foundResourcesAmounts[foundResource]++;
        }

        resources.mintBatch(msg.sender, foundResources, foundResourcesAmounts);

        addressLastSearchTime[msg.sender] = block.timestamp;
    }

    /// @notice TODO: implement crafting according to recipes (burnBatch + mintTo).
    function craft(ItemNFT721.ItemType itemType) external {
        if (itemType == ItemNFT721.ItemType.Saber) {
            uint256[3] memory requiredResources = [resources.IRON(), resources.WOOD(), resources.LEATHER()];
            uint256[3] memory requiredResourcesAmounts = [uint256(3), uint256(1), uint256(1)];

            uint256[] memory burnResources = new uint256[](requiredResources.length);
            uint256[] memory burnResourcesAmounts = new uint256[](requiredResources.length);

            for (uint256 i = 0; i < requiredResources.length; i++) {
                if (!(resources.balanceOf(msg.sender, requiredResources[i]) >= requiredResourcesAmounts[i])) {
                    revert("Not enough recources to craft item");
                }
                burnResources[i] = requiredResources[i];
                burnResourcesAmounts[i] = requiredResourcesAmounts[i];
            }

            items.mintTo(msg.sender, itemType);
            resources.burnBatch(msg.sender, burnResources, burnResourcesAmounts);
        }
    }
}
