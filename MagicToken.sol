// SPDX-License-Identifier: MIT
pragma solidity =0.8.30;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/// @title MagicToken
/// @notice ERC20 токен для ігрової економіки
/// @dev Мінт доступний лише через Marketplace контракт
contract MagicToken is ERC20, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    /// @notice Подія створення токенів
    /// @param to Адреса отримувача
    /// @param amount Кількість токенів
    event TokensMinted(address indexed to, uint256 amount);

    /// @notice Конструктор контракту
    constructor() ERC20("Magic Token", "MAGIC") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /// @notice Створення токенів
    /// @dev Може викликати лише адреса з роллю MINTER_ROLE (Marketplace)
    /// @param to Адреса отримувача
    /// @param amount Кількість токенів для створення
    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {
        require(to != address(0), "Cannot mint to zero address");
        require(amount > 0, "Amount must be greater than 0");
        
        _mint(to, amount);
        emit TokensMinted(to, amount);
    }
}