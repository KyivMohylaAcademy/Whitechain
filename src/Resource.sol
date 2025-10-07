pragma solidity ~0.8.24;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title Resource Contract
/// @notice Manages minting and burning of in-game resource tokens used for crafting and searching.
/// @dev ERC1155-based multi-token contract controlling resources accessible to specific authorized contracts.
contract Resource is ERC1155, Ownable {

    /// @notice Enum representing available types of resources.
    enum Type {
        WOOD,
        IRON,
        STONE,
        LEATHER,
        GOLD,
        DIAMOND
    }

    /// @notice Address of the contract authorized to mint new resources (ResourceSearch contract).
    address private _resourceSearchContract;

    /// @notice Address of the contract authorized to burn resources (ItemCrafting contract).
    address private _itemCraftingContract;

    /// @notice Deploys the Resource contract and assigns the owner.
    /// @param owner The address that will be assigned as the contract owner.
    constructor(address owner) ERC1155("") Ownable(owner) {}

    /// @notice Mints a batch of resource tokens to a specified address.
    /// @dev Only callable by the authorized ResourceSearch contract.
    /// @param to The address that will receive the minted resource tokens.
    /// @param ids The array of resource type identifiers to mint.
    /// @param values The array of corresponding amounts for each resource type.
    function mintBatch(address to, uint256[] calldata ids, uint256[] calldata values) external {
        require(msg.sender == _resourceSearchContract && _resourceSearchContract != address(0));
        _mintBatch(to, ids, values, "");
    }

    /// @notice Burns a batch of resource tokens from a specified address.
    /// @dev Only callable by the authorized ItemCrafting contract.
    /// @param to The address from which resource tokens will be burned.
    /// @param ids The array of resource type identifiers to burn.
    /// @param values The array of corresponding amounts for each resource type to burn.
    function burnBatch(address to, uint256[] calldata ids, uint256[] calldata values) external {
        require(msg.sender == _itemCraftingContract && _itemCraftingContract != address(0));
        _burnBatch(to, ids, values);
    }

    /// @notice Sets the address of the ResourceSearch contract authorized to mint resources.
    /// @dev Only callable by the contract owner.
    /// @param newSearchContract The new ResourceSearch contract address.
    function setSearchContract(address newSearchContract) external onlyOwner {
        _resourceSearchContract = newSearchContract;
    }
    
    /// @notice Sets the address of the ItemCrafting contract authorized to burn resources.
    /// @dev Only callable by the contract owner.
    /// @param newItemCraftingContract The new ItemCrafting contract address.
    function setItemCraftingContract(address newItemCraftingContract) external onlyOwner {
        _itemCraftingContract = newItemCraftingContract;
    }
}
