// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.24;

import "./GameItemNFT721.sol";
import "./MagicToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract GameItemsMarketplace is Ownable {
  error NotTheOwnerOfItem();
  error MarketplaceInsufficientBalance();

  GameItemNFT721 public gameItemContract;
  MagicToken public magicTokenContract;

  mapping(uint => uint256) public itemsTypesPrices;

  constructor(
    address _gameItemContract,
    address _magicTokenContract
  ) Ownable(_msgSender()) {
    gameItemContract = GameItemNFT721(_gameItemContract);
    magicTokenContract = MagicToken(_magicTokenContract);

    uint decimals = magicTokenContract.decimals();

    itemsTypesPrices[gameItemContract.SABER()] = 1 * (10 ** (decimals - 2));
    itemsTypesPrices[gameItemContract.STAFF()] = 2 * (10 ** (decimals - 2));
    itemsTypesPrices[gameItemContract.ARMOR()] = 3 * (10 ** (decimals - 2));
    itemsTypesPrices[gameItemContract.BRACELET()] = 4 * (10 ** (decimals - 2));
  }

  function setItemTypesPrices(uint256 tokenItemType, uint256 price) public onlyOwner {
    itemsTypesPrices[tokenItemType] = price;
  }

  function sellItem(uint256 tokenId) public {
    address owner = gameItemContract.ownerOf(tokenId);

    if (owner != msg.sender) {
      revert NotTheOwnerOfItem();
    }

    uint256 itemType = gameItemContract.tokenItemTypes(tokenId);
    uint256 price = itemsTypesPrices[itemType];

    gameItemContract.burn(tokenId);
    magicTokenContract.mint(owner, price);
  }
}