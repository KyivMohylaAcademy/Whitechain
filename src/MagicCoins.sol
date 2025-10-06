pragma solidity ~0.8.25;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract MagicCoins is ERC20, Ownable {
    address private _marketContract;

    constructor(address owner) ERC20("MagicCoins", "MGC") Ownable(owner) {}

    function mint(address to, uint256 value) external {
        require(msg.sender == _marketContract && _marketContract != address(0));
        _mint(to, value);
    }

    function burn(address from, uint256 value) external {
        require(msg.sender == _marketContract && _marketContract != address(0));
        _burn(from, value);
    }

    function setMarketContract(address marketContract) external onlyOwner {
        _marketContract = marketContract;
    }

}