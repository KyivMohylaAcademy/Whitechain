// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title Resource NFT (ERC1155) for Kosak Business Game
/// @notice Represents basic resources (Wood, Iron, Gold, Leather, Stone, Diamond)
/// @dev Minting is restricted to Crafting or Search contracts

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ResourceNFT1155 is ERC1155, Ownable {
    /// @notice Enum of available resource types
    enum ResourceType { Wood, Iron, Gold, Leather, Stone, Diamond }

    /// @notice Mapping of allowed minters (Crafting, Search)
    mapping(address => bool) public allowedMinters;

    /// @notice Constructor assigns the deployer as owner and sets URI template
    constructor() ERC1155("ipfs://resources/{id}.json") Ownable(msg.sender) {}

    /// @notice Grant mint permission to specific contract (Crafting/Search)
    function setMinter(address minter, bool allowed) external onlyOwner {
        allowedMinters[minter] = allowed;
    }

    /// @notice Mint resource NFT to player (only from allowed contracts)
    function mintResource(address to, uint256 id, uint256 amount) external {
        require(allowedMinters[msg.sender], "Not allowed to mint");
        _mint(to, id, amount, "");
    }

    /// @notice Burn resource NFT (used during crafting)
    function burnResource(address from, uint256 id, uint256 amount) external {
        require(allowedMinters[msg.sender], "Not allowed to burn");
        _burn(from, id, amount);
    }
}
