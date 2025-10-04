// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {ResourceNFT1155} from "./ResourceNFT1155.sol";
import {ItemNFT721} from "./ItemNFT721.sol";

/**
 * @title CraftingSearch
 * @notice Coordinates resource searching with a cooldown and crafts items by burning resources.
 * @dev Uses pseudo-randomness based on block data to mint resources and hard-coded recipes for crafting.
 */
contract CraftingSearch is AccessControl {
    ResourceNFT1155 public resources;
    ItemNFT721 public items;

    // Optional constant for your cooldown if you need it later
    uint256 public constant SEARCH_COOLDOWN = 60 seconds;
    uint256 public constant SEARCH_RESULT_RESOURCE_COUNT = 3;

    uint256 private nonce = 0;

    mapping (address => uint256) public addressLastSearchTime;

    /// @param admin Address that receives the admin role controlling access permissions.
    /// @param _resources Resource contract that handles ERC1155 resource tokens.
    /// @param _items Item contract that handles ERC721 crafted items.
    constructor(address admin, ResourceNFT1155 _resources, ItemNFT721 _items) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        resources = _resources;
        items = _items;
    }

    /// @notice Allows a player to search for resources after the cooldown and mints random materials.
    /// @dev Generates pseudo-random resource IDs using block data and tracks per-address cooldowns.
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

    /// @dev Burns the required resources and mints the crafted item for the caller using prepared recipes;
    ///      reverts if the caller lacks any required amount.
    /// @param itemType Type of item being crafted.
    /// @param requiredResources Ordered array of resource IDs required to craft the item.
    /// @param requiredResourcesAmounts Quantities for each required resource ID.
    /// @return itemId Newly minted item token identifier.
    function _craftItem(ItemNFT721.ItemType itemType, uint256[3] memory requiredResources, uint256[3] memory requiredResourcesAmounts) private returns (uint256) {
            uint256[] memory burnResources = new uint256[](requiredResources.length);
            uint256[] memory burnResourcesAmounts = new uint256[](requiredResources.length);

            for (uint256 i = 0; i < requiredResources.length; i++) {
                if (!(resources.balanceOf(msg.sender, requiredResources[i]) >= requiredResourcesAmounts[i])) {
                    revert("Not enough recources to craft item");
                }
                burnResources[i] = requiredResources[i];
                burnResourcesAmounts[i] = requiredResourcesAmounts[i];
            }

            uint256 itemId = items.mintTo(msg.sender, itemType);
            resources.burnBatch(msg.sender, burnResources, burnResourcesAmounts);
            return itemId;
    }

    /// @notice Crafts an item by checking hard-coded recipes and burning the required resources.
    /// @dev Uses predefined recipes for each supported item type and calls `_craftItem` to mint NFTs;
    ///      unspecified types default to zeroed recipes, effectively minting without burning.
    /// @param itemType Type of item to craft.
    /// @return tokenId Identifier of the newly crafted item.
    function craft(ItemNFT721.ItemType itemType) external returns (uint256) {
        uint256[3] memory requiredResources;
        uint256[3] memory requiredResourcesAmounts;

        if (itemType == ItemNFT721.ItemType.Saber) {
            requiredResources = [resources.IRON(), resources.WOOD(), resources.LEATHER()];
            requiredResourcesAmounts = [uint256(3), uint256(1), uint256(1)];
        } else if (itemType == ItemNFT721.ItemType.Staff) {
            requiredResources = [resources.WOOD(), resources.GOLD(), resources.DIAMOND()];
            requiredResourcesAmounts = [uint256(2), uint256(1), uint256(1)];
        } else if (itemType == ItemNFT721.ItemType.Armor) {
            requiredResources = [resources.LEATHER(), resources.IRON(), resources.GOLD()];
            requiredResourcesAmounts = [uint256(4), uint256(2), uint256(1)];
        } else if (itemType == ItemNFT721.ItemType.Bracelet) {
            requiredResources = [resources.IRON(), resources.GOLD(), resources.DIAMOND()];
            requiredResourcesAmounts = [uint256(4), uint256(2), uint256(2)];
        }

        return _craftItem(itemType, requiredResources, requiredResourcesAmounts);
    }
}
