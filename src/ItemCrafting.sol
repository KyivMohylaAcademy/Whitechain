pragma solidity ~0.8.25;

import "./Item.sol";
import "./Resource.sol";

contract ItemCrafting {

    address private _resourceContract;
    address private _itemContract;

    constructor(address itemContract, address resourceContract)  {
        _resourceContract = resourceContract;
        _itemContract = itemContract;
    }

    function craftItem(Item.Type typ) external {
        uint256[] memory resourcesKind;
        uint256[] memory resourcesAmount;
        (resourcesKind, resourcesAmount) = getResourcesAmountForItem(typ);
        Resource(_resourceContract).burnBatch(msg.sender, resourcesKind, resourcesAmount);
        Item(_itemContract).mintItem(msg.sender, typ);
    }

    function getResourcesAmountForItem(Item.Type typ) internal pure returns(uint256[] memory, uint256[] memory) {
        require(uint(typ) > 0 && uint(typ) <= (uint(type(Item.Type).max) + 1));
        if (typ == Item.Type.SABLE) {
            uint256[] memory resourcesForCraft = new uint256[](3);
            uint256[] memory resourceValues = new uint256[](3);
            resourcesForCraft[0] = uint256(Resource.Type.IRON);
            resourceValues[0] = 3;
            resourcesForCraft[1] = uint256(Resource.Type.WOOD);
            resourceValues[1] = 1; 
            resourcesForCraft[2] = uint256(Resource.Type.LEATHER);
            resourceValues[2] = 1;
            return (resourcesForCraft, resourceValues);
        }
        if (typ == Item.Type.ELDERS_STICK) {
            uint256[] memory resourcesForCraft = new uint256[](3);
            uint256[] memory resourceValues = new uint256[](3);
            resourcesForCraft[0] = uint256(Resource.Type.WOOD);
            resourceValues[0] = 2;
            resourcesForCraft[1] = uint256(Resource.Type.GOLD);
            resourceValues[1] = 1; 
            resourcesForCraft[2] = uint256(Resource.Type.DIAMOND);
            resourceValues[2] = 1;
            return (resourcesForCraft, resourceValues);
        }
        if (typ == Item.Type.ARMOUR) {
            uint256[] memory resourcesForCraft = new uint256[](3);
            uint256[] memory resourceValues = new uint256[](3);
            resourcesForCraft[0] = uint256(Resource.Type.LEATHER);
            resourceValues[0] = 4;
            resourcesForCraft[1] = uint256(Resource.Type.IRON);
            resourceValues[1] = 2; 
            resourcesForCraft[2] = uint256(Resource.Type.GOLD);
            resourceValues[2] = 1;
            return (resourcesForCraft, resourceValues);
        }
        if (typ == Item.Type.BRACE) {
            uint256[] memory resourcesForCraft = new uint256[](3);
            uint256[] memory resourceValues = new uint256[](3);
            resourcesForCraft[0] = uint256(Resource.Type.IRON);
            resourceValues[0] = 4;
            resourcesForCraft[1] = uint256(Resource.Type.GOLD);
            resourceValues[1] = 2; 
            resourcesForCraft[2] = uint256(Resource.Type.DIAMOND);
            resourceValues[2] = 2;
            return (resourcesForCraft, resourceValues);
        }
    }
    
}