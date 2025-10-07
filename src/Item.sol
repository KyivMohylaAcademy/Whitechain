pragma solidity ~0.8.24;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Resource} from "./Resource.sol";

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

    constructor(address contractOwner) Ownable(contractOwner) {
        _itemIdCounter = 1;
    }

    function mintItem(address crafter, Type typ) external {
        require(_itemCraftingContract != address(0) && msg.sender == _itemCraftingContract);
        _mint(crafter, _itemIdCounter);
        _itemToType[_itemIdCounter] = typ;
        _itemIdCounter++;
    }

    function marketTransfer(address from, address to, uint256 tokenId) external {
        require(msg.sender == _marketplaceContract && _marketplaceContract != address(0));
        _update(to, tokenId, from);
    }

    function getType(uint256 id) external view returns (Type) {
        return _itemToType[id];
    }

    function setItemCraftingContract(address itemCraftingContract) external onlyOwner {
        _itemCraftingContract = itemCraftingContract;
    }

    function setMarketplaceContract(address marketplaceContract) external onlyOwner {
        _marketplaceContract = marketplaceContract;
    }
}