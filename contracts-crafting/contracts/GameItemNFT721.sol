// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.24;

import {ERC721URIStorage, ERC721} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract GameItemNFT721 is ERC721URIStorage, AccessControl {
  error InvalidTokenItemType(uint tokenItemType);

  uint public constant SABER = 0;
  uint public constant STAFF = 1;
  uint public constant ARMOR = 2;
  uint public constant BRACELET = 3;

  bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
  bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

  uint256 private _nextTokenId = 0;

  mapping(uint256 => uint) public tokenItemTypes;

  constructor() ERC721("Cossak Business Game Item", "CGI") {
    _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
  }

  function mint(address account, uint tokenItemType) public onlyRole(MINTER_ROLE) {
    if (tokenItemType > 3) {
      revert InvalidTokenItemType(tokenItemType);
    }

    uint256 tokenId = _nextTokenId++;

    _mint(account, tokenId);
    _setTokenURI(tokenId, string.concat("https://cossak-business.com.ua/items/", _itemURIPrefix(tokenItemType), "/", Strings.toString(tokenId), ".json"));
    tokenItemTypes[tokenId] = tokenItemType;
  }

  function burn(uint id) public onlyRole(BURNER_ROLE) {
    _burn(id);
  }

  function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721URIStorage, AccessControl) returns (bool) {
    return super.supportsInterface(interfaceId);
  }

  function _itemURIPrefix(uint tokenItemType) internal pure returns (string memory) {
    if (tokenItemType == SABER) {
      return "saber";
    } else if (tokenItemType == STAFF) {
      return "staff";
    } else if (tokenItemType == ARMOR) {
      return "armor";
    }

    return "bracelet";
  }
}