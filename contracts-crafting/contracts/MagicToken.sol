// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract MagicToken is ERC20, AccessControl {
  bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

  constructor() ERC20("Cossacks Business Magic Token", "CBMT") {
    _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
  }

  function mint(address account, uint256 amount) public onlyRole(MINTER_ROLE) {
    _mint(account, amount);
  }
}