pragma solidity ~0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title Magic Coins Token
/// @notice ERC20 token representing in-game currency used for market operations.
/// @dev Only the assigned market contract can mint or burn tokens.
contract MagicCoins is ERC20, Ownable {
    /// @notice Address of the market contract authorized to mint and burn tokens.
    address private _marketContract;

    /// @notice Deploys the MagicCoins contract and assigns ownership.
    /// @param owner The address that will be set as the contract owner.
    constructor(address owner) ERC20("MagicCoins", "MGC") Ownable(owner) {}

    /// @notice Mints new MagicCoins to a specified address.
    /// @dev Can only be called by the assigned market contract.
    /// @param to The address that will receive the newly minted tokens.
    /// @param value The amount of tokens to mint.
    function mint(address to, uint256 value) external {
        require(msg.sender == _marketContract && _marketContract != address(0));
        _mint(to, value);
    }

    /// @notice Burns MagicCoins from a specified address.
    /// @dev Can only be called by the assigned market contract.
    /// @param from The address from which tokens will be burned.
    /// @param value The amount of tokens to burn.
    function burn(address from, uint256 value) external {
        require(msg.sender == _marketContract && _marketContract != address(0));
        _burn(from, value);
    }

    /// @notice Sets the address of the market contract.
    /// @dev Only the contract owner can change this address.
    /// @param marketContract The address of the market contract authorized to mint and burn tokens.
    function setMarketContract(address marketContract) external onlyOwner {
        _marketContract = marketContract;
    }

}
