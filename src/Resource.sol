pragma solidity ~0.8.24;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract Resource is ERC1155, Ownable {

    enum Type {
        WOOD,
        IRON,
        STONE,
        LEATHER,
        GOLD,
        DIAMOND
    }

    address private _resourceSearchContract;
    address private _itemCraftingContract;
    constructor(address owner) ERC1155("") Ownable(owner) {}

    function mintBatch(address to, uint256[] calldata ids, uint256[] calldata values) external {
        require(msg.sender == _resourceSearchContract && _resourceSearchContract != address(0));
        _mintBatch(to, ids, values, "");
    }

    function burnBatch(address to, uint256[] calldata ids, uint256[] calldata values) external {
        require(msg.sender == _itemCraftingContract && _itemCraftingContract != address(0));
        _burnBatch(to, ids, values);
    }

    function setSearchContract(address newSearchContract) external onlyOwner {
        _resourceSearchContract = newSearchContract;
    }
    
    function setItemCraftingContract(address newItemCraftingContract) external onlyOwner {
        _itemCraftingContract = newItemCraftingContract;
    }
}

