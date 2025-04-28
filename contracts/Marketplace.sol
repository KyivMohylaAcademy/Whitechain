// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./ERC20VotingToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Marketplace is Ownable {
    ERC20VotingToken public token;

    constructor(address tokenAddress) Ownable(msg.sender) {
        token = ERC20VotingToken(tokenAddress);
    }

    function buyTokens() external payable {
        require(msg.value > 0, "Send ETH to buy tokens");
        token.mint(msg.sender, msg.value / 1e15); // 0.001 ETH = 1 токен
    }

    function sellTokens(uint256 amount) external {
        require(token.balanceOf(msg.sender) >= amount, "Not enough tokens");
        token.burn(msg.sender, amount);
        payable(msg.sender).transfer(amount * 1e15); // ціна викупу
    }

    receive() external payable {}
}
