pragma solidity ~0.8.25;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract Resource is ERC1155 {
    address private _resourceSearchContract;
    address private _owner;
    constructor(address owner) ERC1155("") {
        _resourceSearchContract = address(0);
        _owner = owner;
    }

    function mintBatch(address to, uint256[] calldata ids, uint256[] calldata values) external {
        require(msg.sender == _resourceSearchContract);
        _mintBatch(to, ids, values, "");
    }

    function setOwner(address newOwner) external {
        require(msg.sender == _owner);
        _owner = newOwner;
    }

    function setSearchContract(address newSearchContract) external {
        require(msg.sender == _owner);
        _resourceSearchContract = newSearchContract;
    }
}

