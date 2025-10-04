// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title ItemNFT721
 * @notice ERC721 collection for crafted items with role-restricted minting and burning.
 */
contract ItemNFT721 is ERC721, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE"); // assign to CraftingSearch
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE"); // assign to CraftingSearch
    uint256 public nextId = 0;

    enum ItemType {Saber, Staff, Armor, Bracelet}

    struct Item {
        ItemType itemType;
    }

    mapping (uint256 => Item) public items;

    /// @param admin Address that receives the admin role to manage minter and burner permissions.
    constructor(address admin) ERC721("Cossack Items", "CITEM") {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
    }

    /// @notice Mints an item NFT with the provided type to the target address.
    /// @param to Recipient of the newly minted item.
    /// @param itemType Item classification stored alongside the token ID.
    /// @return id Newly created token identifier.
    function mintTo(
        address to, ItemType itemType
    ) external onlyRole(MINTER_ROLE) returns (uint256) {
        uint256 id = nextId;

        items[id] = Item(itemType);

        _safeMint(to, id);
        nextId++;

        return id;
    }

    /// @notice Burns an existing item token when called by an authorized burner.
    /// @param tokenId Identifier of the token to destroy.
    function burn(uint256 tokenId) external onlyRole(BURNER_ROLE) {
        _burn(tokenId);
    }

    /// @notice Checks interface support for ERC721 and AccessControl features.
    /// @param interfaceId Identifier of the interface to query.
    /// @return supported True if the contract supports the provided interface ID.
    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
