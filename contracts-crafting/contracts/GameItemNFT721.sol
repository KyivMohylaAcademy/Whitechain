// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.24;

import {ERC721URIStorage, ERC721} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/// @title Cossak Business Game Item NFT (ERC721)
/// @author Artem Tarasenko (@shabashab)
/// @notice ERC721 NFT contract for game items with item types and role-based access control
/// @dev Extends OpenZeppelin ERC721URIStorage and AccessControl
contract GameItemNFT721 is ERC721URIStorage, AccessControl {
    /// @notice Error thrown when an invalid item type is used
    /// @param tokenItemType The invalid item type provided
    error InvalidTokenItemType(uint tokenItemType);

    /// @notice Item type constant for Saber
    uint public constant SABER = 0;
    /// @notice Item type constant for Staff
    uint public constant STAFF = 1;
    /// @notice Item type constant for Armor
    uint public constant ARMOR = 2;
    /// @notice Item type constant for Bracelet
    uint public constant BRACELET = 3;

    /// @notice Role required to mint new NFTs
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    /// @notice Role required to burn NFTs
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    /// @dev Next token ID to be minted
    uint256 private _nextTokenId = 0;

    /// @notice Mapping from token ID to item type
    /// @dev tokenItemTypes[tokenId] returns the item type for a given tokenId
    mapping(uint256 => uint) public tokenItemTypes;

    /// @notice Contract constructor, sets up ERC721 and grants admin role to deployer
    constructor() ERC721("Cossak Business Game Item", "CGI") {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    /// @notice Mint a new game item NFT to a specified address
    /// @dev Only accounts with MINTER_ROLE can call this function
    /// @param account The address that will receive the NFT
    /// @param tokenItemType The type of item to mint (0 = Saber, 1 = Staff, 2 = Armor, 3 = Bracelet)
    /// @custom:throws InvalidTokenItemType if tokenItemType > 3
    function mint(address account, uint tokenItemType) public onlyRole(MINTER_ROLE) {
        if (tokenItemType > 3) {
            revert InvalidTokenItemType(tokenItemType);
        }

        uint256 tokenId = _nextTokenId++;

        _mint(account, tokenId);
        _setTokenURI(tokenId, string.concat("https://cossak-business.com.ua/items/", _itemURIPrefix(tokenItemType), "/", Strings.toString(tokenId), ".json"));
        tokenItemTypes[tokenId] = tokenItemType;
    }

    /// @notice Burn an existing NFT by token ID
    /// @dev Only accounts with BURNER_ROLE can call this function
    /// @param id The token ID to burn
    function burn(uint id) public onlyRole(BURNER_ROLE) {
        _burn(id);
    }

    /// @notice Checks whether the contract supports a given interface
    /// @dev Overrides supportsInterface from both ERC721URIStorage and AccessControl
    /// @param interfaceId The interface identifier, as specified in ERC-165
    /// @return True if the contract supports the given interface
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721URIStorage, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /// @notice Returns the URI prefix for a given item type
    /// @dev Used internally to construct token URIs
    /// @param tokenItemType The type of item (0 = Saber, 1 = Staff, 2 = Armor, 3 = Bracelet)
    /// @return The string prefix for the item type in the URI
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
