pragma solidity ~0.8.25;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Resource} from "./Resource.sol";

contract Item is ERC721("Item", "IM"), Ownable {
    enum Type {
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
        require(msg.sender == _itemCraftingContract && _itemCraftingContract != address(0));
        uint256 itemId = _itemIdCounter++;
        _mint(crafter, itemId);
        _itemToType[itemId] = typ;
    }

    function marketTransfer(address from, address to, uint256 tokenId) external {
        require(msg.sender == _marketplaceContract && _marketplaceContract != address(0));
        _update(to, tokenId, from);
    }

    function setItemCraftingContract(address itemCraftingContract) external onlyOwner {
        _itemCraftingContract = itemCraftingContract;
    }

    function setMarketplaceContract(address marketplaceContract) external onlyOwner {
        _marketplaceContract = marketplaceContract;
    }
}