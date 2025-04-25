// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.24;

import "./ResourceNFT1155.sol";
import "./GameItemNFT721.sol";
import "@openzeppelin/contracts/utils/Context.sol";

/// @title Resource Crafting Contract
/// @author Artem Tarasenko (@shabashab)
/// @notice Allows users to craft in-game items (ERC721) by consuming resources (ERC1155) according to recipes
/// @dev Integrates with ResourceNFT1155 and GameItemNFT721 contracts. Recipes are set in the constructor.
contract ResourceCrafting is Context {
    /// @notice Thrown when user does not have enough resources to craft an item
    /// @param resourceId The resource required
    /// @param requiredAmount The required amount of this resource
    /// @param availableAmount The user's available amount of this resource
    error InsufficientResources(uint resourceId, uint requiredAmount, uint availableAmount);

    /// @notice Thrown when a recipe for the given recipeId does not exist
    /// @param recipeId The requested recipe/item type
    error InvalidRecipeIndex(uint recipeId);

    /// @notice The ERC1155 resource contract used for crafting
    ResourceNFT1155 public resourceContract;
    /// @notice The ERC721 game item contract that is minted as a result of crafting
    GameItemNFT721 public gameItemContract;

    /// @notice Structure describing a single resource requirement for a recipe
    /// @param resourceId The ID of the required resource
    /// @param amount The amount of the resource required
    struct RecipeResourceEntry {
        uint resourceId;
        uint amount;
    }

    /// @notice Mapping from recipeId (item type) to an array of required resources for crafting
    /// @dev recipesResources[recipeId] gives the array of RecipeResourceEntry for that item
    mapping(uint => RecipeResourceEntry[]) public recipesResources;

    /// @notice Initializes the contract with resource and item contracts and sets up recipes for crafting
    /// @param _resourceContract Address of the ResourceNFT1155 contract
    /// @param _gameItemContract Address of the GameItemNFT721 contract
    constructor(
        address _resourceContract,
        address _gameItemContract
    ) {
        resourceContract = ResourceNFT1155(_resourceContract);
        gameItemContract = GameItemNFT721(_gameItemContract);

        uint iron = resourceContract.IRON();
        uint wood = resourceContract.WOOD();
        uint leather = resourceContract.LEATHER();
        uint gold = resourceContract.GOLD();
        uint diamond = resourceContract.DIAMOND();

        uint saber = gameItemContract.SABER();
        uint staff = gameItemContract.STAFF();
        uint armor = gameItemContract.ARMOR();
        uint bracelet = gameItemContract.BRACELET();

        // Saber Recipe: 3 Iron, 1 Wood, 1 Leather
        RecipeResourceEntry[] storage saberRecipe = recipesResources[saber];
        saberRecipe.push(RecipeResourceEntry(iron, 3));
        saberRecipe.push(RecipeResourceEntry(wood, 1));
        saberRecipe.push(RecipeResourceEntry(leather, 1));

        // Staff Recipe: 2 Wood, 1 Gold, 1 Diamond
        RecipeResourceEntry[] storage staffRecipe = recipesResources[staff];
        staffRecipe.push(RecipeResourceEntry(wood, 2));
        staffRecipe.push(RecipeResourceEntry(gold, 1));
        staffRecipe.push(RecipeResourceEntry(diamond, 1));

        // Armor Recipe: 4 Leather, 2 Iron, 1 Gold
        RecipeResourceEntry[] storage armorRecipe = recipesResources[armor];
        armorRecipe.push(RecipeResourceEntry(leather, 4));
        armorRecipe.push(RecipeResourceEntry(iron, 2));
        armorRecipe.push(RecipeResourceEntry(gold, 1));

        // Bracelet Recipe: 4 Iron, 2 Gold, 2 Diamond
        RecipeResourceEntry[] storage braceletRecipe = recipesResources[bracelet];
        braceletRecipe.push(RecipeResourceEntry(iron, 4));
        braceletRecipe.push(RecipeResourceEntry(gold, 2));
        braceletRecipe.push(RecipeResourceEntry(diamond, 2));
    }

    /// @notice Craft a game item by consuming the required resources according to a recipe
    /// @dev Reverts if recipe does not exist or user lacks required resources.
    ///      Burns resources and mints the crafted item.
    /// @param recipeId The ID of the item to craft (corresponds to item type in GameItemNFT721)
    /// @custom:throws InvalidRecipeIndex if the recipe does not exist
    /// @custom:throws InsufficientResources if the sender does not have enough of any required resource
    function craftItem(uint recipeId) external {
        RecipeResourceEntry[] memory recipe = recipesResources[recipeId];

        if (recipe.length == 0) {
            revert InvalidRecipeIndex(recipeId);
        }

        for (uint i = 0; i < recipe.length; i++) {
            RecipeResourceEntry memory entry = recipe[i];
            uint balance = resourceContract.balanceOf(_msgSender(), recipe[i].resourceId);

            if (balance < entry.amount) {
                revert InsufficientResources(entry.resourceId, entry.amount, balance);
            }

            resourceContract.burn(_msgSender(), entry.resourceId, entry.amount);
        }

        gameItemContract.mint(_msgSender(), recipeId); 
    }
}
