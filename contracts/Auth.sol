// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Web3 Auth Contract
/// @author Anna Tsvetkova
/// @notice Зберігає факт авторизації користувача
contract Auth {
    mapping(address => bool) public isAuthenticated;

    /// @notice Авторизувати користувача
    function authenticate() external {
        require(!isAuthenticated[msg.sender], "Already authenticated");
        isAuthenticated[msg.sender] = true;
    }

    /// @notice Перевірити статус
    /// @param user Адреса користувача
    /// @return Чи був авторизований користувач
    function isAuth(address user) external view returns (bool) {
        return isAuthenticated[user];
    }
}
