// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/// @title Cossacks Business Magic Token (CBMT)
/// @author Artem Tarasenko (@shabashab)
/// @notice ERC20 token with role-based minting for the Cossacks Business ecosystem
/// @dev Inherits from OpenZeppelin ERC20 and AccessControl for permissioned minting
contract MagicToken is ERC20, AccessControl {
    /// @notice Role identifier for accounts allowed to mint new tokens
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    /// @notice Deploys the MagicToken contract and grants admin role to the deployer
    constructor() ERC20("Cossacks Business Magic Token", "CBMT") {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    /// @notice Mint new tokens to a specified account
    /// @dev Only accounts with MINTER_ROLE can call this function
    /// @param account The address to receive the minted tokens
    /// @param amount The amount of tokens to mint (in the smallest unit)
    function mint(address account, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(account, amount);
    }
}
