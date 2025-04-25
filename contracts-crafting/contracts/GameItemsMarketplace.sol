// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.24;

import "./GameItemNFT721.sol";
import "./MagicToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Game Items Marketplace
/// @author Artem Tarasenko (@shabashab)
/// @notice Marketplace contract for selling game item NFTs for MagicToken
/// @dev Allows users to sell their GameItemNFT721 tokens for MagicToken. Only the owner can set prices.
contract GameItemsMarketplace is Ownable {
    /// @notice Thrown when a caller is not the owner of the specified NFT
    error NotTheOwnerOfItem();
    /// @notice Thrown when the marketplace does not have enough balance (not used in current logic)
    error MarketplaceInsufficientBalance();

    /// @notice The GameItemNFT721 contract instance
    GameItemNFT721 public gameItemContract;
    /// @notice The MagicToken contract instance
    MagicToken public magicTokenContract;

    /// @notice Mapping from item type to sale price in MagicToken
    /// @dev itemsTypesPrices[itemType] returns the price for the given item type
    mapping(uint => uint256) public itemsTypesPrices;

    /// @notice Initializes the marketplace with NFT and token contract addresses, and sets default prices
    /// @param _gameItemContract Address of the GameItemNFT721 contract
    /// @param _magicTokenContract Address of the MagicToken contract
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

    /// @notice Set the price for a specific item type
    /// @dev Only the contract owner can set prices
    /// @param tokenItemType The item type to set the price for
    /// @param price The new price in MagicToken (with decimals)
    function setItemTypesPrices(uint256 tokenItemType, uint256 price) public onlyOwner {
        itemsTypesPrices[tokenItemType] = price;
    }

    /// @notice Sell a game item NFT in exchange for MagicToken
    /// @dev Burns the NFT and mints MagicToken to the seller. Caller must own the NFT.
    /// @param tokenId The token ID of the NFT to sell
    /// @custom:throws NotTheOwnerOfItem if the caller is not the owner of the NFT
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
