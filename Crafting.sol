// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Crafting contract forKosak Business Game
/// @notice Handles resource searching and item crafting
/// @dev Works with ResourceNFT1155 and ItemNFT721 contracts

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./ResourceNFT1155.sol";
import "./ItemNFT721.sol";

contract Crafting is Ownable {
    using Strings for uint256;

    /// @notice Reference to ResourceNFT1155 contract
    ResourceNFT1155 public resourceContract;

    /// @notice Reference to ItemNFT721 contract
    ItemNFT721 public itemContract;

    /// @notice Cooldown time between searches
    uint256 public constant SEARCH_COOLDOWN = 60; // 60 seconds

    /// @notice Track last search time per player
    mapping(address => uint256) public lastSearchTime;

    /// @notice Item crafting recipes
    struct Recipe {
        uint256[] resourceIds;
        uint256[] amounts;
        string name;
        string metadataURI;
    }

    /// @notice Mapping from item type to recipe
    mapping(uint8 => Recipe) public recipes;

    /// @notice Initialize with references to resource & item contracts
    constructor(address _resource, address _item) Ownable(msg.sender) {
        resourceContract = ResourceNFT1155(_resource);
        itemContract = ItemNFT721(_item);
    }

    /// @notice Allow owner to define crafting recipes
    function setRecipe(
        uint8 itemType,
        uint256[] memory resourceIds,
        uint256[] memory amounts,
        string memory name,
        string memory metadataURI
    ) external onlyOwner {
        recipes[itemType] = Recipe(resourceIds, amounts, name, metadataURI);
    }

    /// @notice Player searches for random resources (every 60 sec)
    function searchResources() external {
        require(
            block.timestamp - lastSearchTime[msg.sender] >= SEARCH_COOLDOWN,
            "Wait before next search"
        );
        lastSearchTime[msg.sender] = block.timestamp;

        // Generate 3 random resources (pseudo-randomly)
        for (uint256 i = 0; i < 3; i++) {
            uint256 resourceId = uint256(
                keccak256(
                    abi.encodePacked(block.timestamp, msg.sender, i)
                )
            ) % 6; // 6 types: 0-5

            resourceContract.mintResource(msg.sender, resourceId, 1);
        }
    }

    /// @notice Craft item from resources
    /// @param itemType Index of recipe
    function craftItem(uint8 itemType) external {
        Recipe memory recipe = recipes[itemType];
        require(recipe.resourceIds.length > 0, "Recipe not found");

        // Burn required resources
        for (uint256 i = 0; i < recipe.resourceIds.length; i++) {
            resourceContract.burnResource(
                msg.sender,
                recipe.resourceIds[i],
                recipe.amounts[i]
            );
        }

        // Mint new item NFT
        itemContract.mintItem(
            msg.sender,
            recipe.name,
            recipe.metadataURI
        );
    }
}
