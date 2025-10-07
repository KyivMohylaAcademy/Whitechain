pragma solidity ~0.8.24;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Resource} from "./Resource.sol";

/// @title Item NFT Contract
/// @notice Represents unique in-game items as ERC721 tokens with different types
/// @dev Only the ItemCrafting contract can mint, and only the Marketplace contract can transfer between users
contract Item is ERC721("Item", "IM"), Ownable {
    enum Type {
        NONE,
        SABLE,
        ELDERS_STICK,
        ARMOUR,
        BRACE
    }
    
    address private _itemCraftingContract;
    address private _marketplaceContract;
    uint256 private _itemIdCounter;

    mapping(uint256 id => Type) private _itemToType;

    /// @notice Deploys the Item contract and sets the contract owner
    /// @param contractOwner The address that will be assigned as the owner that is able to manage dependent contracts
    constructor(address contractOwner) Ownable(contractOwner) {
        _itemIdCounter = 1;
    }

    /// @notice Mints a new item NFT to the specified crafter
    /// @dev Can only be called by the authorized item crafting contract
    /// @param crafter Address that will receive the newly minted item
    /// @param typ Enum value representing the type of item to mint
    function mintItem(address crafter, Type typ) external {
        require(_itemCraftingContract != address(0) && msg.sender == _itemCraftingContract);
        _mint(crafter, _itemIdCounter);
        _itemToType[_itemIdCounter] = typ;
        _itemIdCounter++;
    }

    /// @notice Transfers an item NFT from one address to another via marketplace
    /// @dev Can only be called by the authorized marketplace contract
    /// @param from Current owner of the token (supports approvals)
    /// @param to New owner of the token
    /// @param tokenId ID of the token to transfer
    function marketTransfer(address from, address to, uint256 tokenId) external {
        require(msg.sender == _marketplaceContract && _marketplaceContract != address(0));
        _update(to, tokenId, from);
    }

    /// @notice Gets the type of a specific item by its token ID
    /// @param id The token ID of the item
    /// @return The item type as defined in the Type enum
    function getType(uint256 id) external view returns (Type) {
        return _itemToType[id];
    }

    /// @notice Sets the address of the item crafting contract
    /// @dev Only callable by the contract owner
    /// @param itemCraftingContract The address of the item crafting contract
    function setItemCraftingContract(address itemCraftingContract) external onlyOwner {
        _itemCraftingContract = itemCraftingContract;
    }

    /// @notice Sets the address of the marketplace contract
    /// @dev Only callable by the contract owner
    /// @param marketplaceContract The address of the marketplace contract
    function setMarketplaceContract(address marketplaceContract) external onlyOwner {
        _marketplaceContract = marketplaceContract;
    }
}
