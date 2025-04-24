// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.24;

import "./ResourceNFT1155.sol";
import "./GameItemNFT721.sol";
import "@openzeppelin/contracts/utils/Context.sol";

contract ResourceCrafting is Context {
  error InsufficientResources(uint resourceId, uint requiredAmount, uint availableAmount);
  error InvalidRecipeIndex(uint recipeId);

  ResourceNFT1155 public resourceContract;
  GameItemNFT721 public gameItemContract;

  struct RecipeResourceEntry {
    uint resourceId;
    uint amount;
  }

  mapping(uint => RecipeResourceEntry[]) public recipesResources;

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

    RecipeResourceEntry[] storage saberRecipe = recipesResources[saber];
    saberRecipe.push(RecipeResourceEntry(iron, 3));
    saberRecipe.push(RecipeResourceEntry(wood, 1));
    saberRecipe.push(RecipeResourceEntry(leather, 1));

    RecipeResourceEntry[] storage staffRecipe = recipesResources[staff];
    staffRecipe.push(RecipeResourceEntry(wood, 2));
    staffRecipe.push(RecipeResourceEntry(gold, 1));
    staffRecipe.push(RecipeResourceEntry(diamond, 1));

    RecipeResourceEntry[] storage armorRecipe = recipesResources[armor];
    armorRecipe.push(RecipeResourceEntry(leather, 4));
    armorRecipe.push(RecipeResourceEntry(iron, 2));
    armorRecipe.push(RecipeResourceEntry(gold, 1));

    RecipeResourceEntry[] storage braceletRecipe = recipesResources[bracelet];
    braceletRecipe.push(RecipeResourceEntry(iron, 4));
    braceletRecipe.push(RecipeResourceEntry(gold, 2));
    braceletRecipe.push(RecipeResourceEntry(diamond, 2));
  }

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