// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.24;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract ResourceNFT1155 is ERC1155, AccessControl {
  uint public constant WOOD = 0;
  uint public constant IRON = 1;
  uint public constant GOLD = 2;
  uint public constant LEATHER = 3;
  uint public constant STONE = 4;
  uint public constant DIAMOND = 5;

  bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
  bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

  constructor() ERC1155("https://cossak-business.com.ua/resources/{id}.json") {
    _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
  }

  function mint(address account, uint id, uint amount) public onlyRole(MINTER_ROLE) {
    _mint(account, id, amount, "");
  }

  function burn(address account, uint id, uint amount) public onlyRole(BURNER_ROLE) {
    _burn(account, id, amount);
  }

  function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, AccessControl) returns (bool) {
    return super.supportsInterface(interfaceId);
  }
}
