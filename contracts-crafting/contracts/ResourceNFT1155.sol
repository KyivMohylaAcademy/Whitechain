// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.24;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/// @title Resource NFT (ERC1155) for Cossacks Business
/// @author Artem Tarasenko (@shabashab)
/// @notice Multi-token contract for in-game resources with role-based minting and burning
/// @dev Extends OpenZeppelin ERC1155 and AccessControl for resource management and permissions
contract ResourceNFT1155 is ERC1155, AccessControl {
    /// @notice Resource type constant for Wood (id = 0)
    uint public constant WOOD = 0;
    /// @notice Resource type constant for Iron (id = 1)
    uint public constant IRON = 1;
    /// @notice Resource type constant for Gold (id = 2)
    uint public constant GOLD = 2;
    /// @notice Resource type constant for Leather (id = 3)
    uint public constant LEATHER = 3;
    /// @notice Resource type constant for Stone (id = 4)
    uint public constant STONE = 4;
    /// @notice Resource type constant for Diamond (id = 5)
    uint public constant DIAMOND = 5;

    /// @notice Role identifier for accounts allowed to mint resources
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    /// @notice Role identifier for accounts allowed to burn resources
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

    /// @notice Deploys the ResourceNFT1155 contract and grants admin role to the deployer
    constructor() ERC1155("https://cossak-business.com.ua/resources/{id}.json") {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    /// @notice Mint a specific amount of a resource to an account
    /// @dev Only accounts with MINTER_ROLE can call this function
    /// @param account The address to receive the newly minted resources
    /// @param id The resource type ID to mint (see resource constants)
    /// @param amount The amount of the resource to mint
    function mint(address account, uint id, uint amount) public onlyRole(MINTER_ROLE) {
        _mint(account, id, amount, "");
    }

    /// @notice Burn a specific amount of a resource from an account
    /// @dev Only accounts with BURNER_ROLE can call this function
    /// @param account The address from which to burn the resources
    /// @param id The resource type ID to burn (see resource constants)
    /// @param amount The amount of the resource to burn
    function burn(address account, uint id, uint amount) public onlyRole(BURNER_ROLE) {
        _burn(account, id, amount);
    }

    /// @notice Checks if the contract supports a given interface
    /// @dev Overrides supportsInterface from ERC1155 and AccessControl
    /// @param interfaceId The interface identifier, as specified in ERC-165
    /// @return True if the contract supports the given interface
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
