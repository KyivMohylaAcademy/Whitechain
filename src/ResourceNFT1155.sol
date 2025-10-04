// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title ResourceNFT1155
 * @notice ERC1155 contract that manages resource tokens with role-gated minting and burning.
 */
contract ResourceNFT1155 is ERC1155, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE"); // assign to CraftingSearch
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE"); // assign to CraftingSearch

    /// @notice Example resource identifiers used by the crafting system.
    uint256 public constant WOOD = 0;
    uint256 public constant IRON = 1;
    uint256 public constant GOLD = 2;
    uint256 public constant LEATHER = 3;
    uint256 public constant STONE = 4;
    uint256 public constant DIAMOND = 5;

    uint256[] public resourceIds = [WOOD, IRON, GOLD, LEATHER, STONE, DIAMOND];

    /// @notice Returns the list of predefined resource identifiers.
    /// @return ids Array of supported resource IDs.
    function getResourceIds() external view returns (uint256[] memory) {
        return resourceIds;
    }

    /// @notice Calculates the aggregate balance across all resource IDs for an account.
    /// @param account Address to query.
    /// @return balance Total quantity of all resources held by the account.
    function totalBalanceOf(address account) external view returns (uint256){
        uint256 balance = 0;

        for (uint256 i = 0; i < resourceIds.length; i++) {
            balance += balanceOf(account, resourceIds[i]);
        }

        return balance;
    }

    /// @param admin Address that receives the admin role to delegate minter and burner permissions.
    constructor(address admin) ERC1155("") {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
    }

    /// @notice Mints a batch of resource tokens to the specified address.
    /// @dev Intended to be called by authorized contracts such as CraftingSearch.
    /// @param to Recipient of the resources.
    /// @param ids Identifiers of resources to mint.
    /// @param amounts Quantities to mint for each resource ID.
    function mintBatch(
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts
    ) external onlyRole(MINTER_ROLE) {
        _mintBatch(to, ids, amounts, "");
    }

    /// @notice Burns a batch of resource tokens from the specified address.
    /// @dev Intended to be called by authorized contracts such as CraftingSearch.
    /// @param from Address whose resources will be burned.
    /// @param ids Identifiers of resources to burn.
    /// @param amounts Quantities to burn for each resource ID.
    function burnBatch(
        address from,
        uint256[] calldata ids,
        uint256[] calldata amounts
    ) external onlyRole(BURNER_ROLE) {
        _burnBatch(from, ids, amounts);
    }

    /// @notice Mints a single resource entry.
    /// @param to Recipient of the minted resource.
    /// @param id Identifier of the resource to mint.
    /// @param amount Quantity to mint.
    function mint(address to, uint256 id, uint256 amount) external onlyRole(MINTER_ROLE) {
        _mint(to, id, amount, "");
    }

    /// @inheritdoc ERC1155
    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
