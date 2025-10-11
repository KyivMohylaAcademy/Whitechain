// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title MagicToken
 * @notice ERC20 token used as marketplace currency with role-restricted minting.
 */
contract MagicToken is ERC20, AccessControl {
    bytes32 public constant MARKET_ROLE = keccak256("MARKET_ROLE"); // assign to Marketplace

    /// @param admin Address that receives the admin role for assigning marketplace permissions.
    constructor(address admin) ERC20("Magic Token", "MAGIC") {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
    }

    /// @notice Mints marketplace tokens to the provided account when called by an authorized role.
    /// @param to Recipient of the minted tokens.
    /// @param amount Number of tokens to mint.
    function mint(address to, uint256 amount) external onlyRole(MARKET_ROLE) {
        _mint(to, amount);
    }

    /// @notice Burns tokens from an account, spending allowance when required.
    /// @param from Account whose tokens will be destroyed.
    /// @param amount Number of tokens to burn.
    function burnFrom(address from, uint256 amount) external onlyRole(MARKET_ROLE) {
        if (from != _msgSender()) {
            _spendAllowance(from, _msgSender(), amount);
        }

        _burn(from, amount);
    }
}
