// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ResourceNFT1155.sol";

/// @title Resource Search Contract
/// @author Artem Tarasenko (@shabashab)
/// @notice Allows users to search for and receive random in-game resources, with a cooldown per user
/// @dev Integrates with ResourceNFT1155 for minting resources, and uses a simple pseudo-random generator for resource selection
contract ResourceSearch is Ownable {
    /// @notice Thrown when a user tries to search for resources before their cooldown has expired
    error TooManyAttempts();

    /// @notice Number of resources generated per search
    uint256 public resourcesPerSearch = 3;

    /// @notice Cooldown time (in seconds) between resource searches for each user
    uint256 public resourceSearchCooldown = 60 seconds;

    /// @notice The ResourceNFT1155 contract used for minting resources
    ResourceNFT1155 public resourceContract;

    /// @notice Mapping of user address to the timestamp of their last resource search
    /// @dev lastSearchedResources[user] returns the last time the user performed a search
    mapping(address => uint256) public lastSearchedResources;

    /// @notice Deploys the contract and sets the resource contract address
    /// @param _resourceContract The address of the ResourceNFT1155 contract
    constructor(
        address _resourceContract
    ) Ownable(_msgSender()) {
        resourceContract = ResourceNFT1155(_resourceContract);
    }

    /// @notice Allows a user to search for resources and receive a random distribution, subject to cooldown
    /// @dev Uses block timestamp and sender address for pseudo-randomness. Prevents reentrancy by updating last search timestamp before minting.
    /// @return resourcesCountToGenerate Array of length 6, each entry is the number of resources of that type awarded to the user
    /// @custom:throws TooManyAttempts if the user is still on cooldown
    function searchResources() external returns (uint256[] memory) {
        if(lastSearchedResources[msg.sender] + resourceSearchCooldown > block.timestamp) {
            revert TooManyAttempts();
        }

        // It is important that we keep the update here, because
        // minting calls onERC1155Received on receiving smart contract
        // and otherwise could be abused to call this function again
        // which will result in reentrancy attack (and user getting infinite resources)
        lastSearchedResources[msg.sender] = block.timestamp;

        uint256[] memory resourcesCountToGenerate = new uint256[](6);

        for(uint256 i = 0; i < resourcesPerSearch; i++) {
            uint256 resourceId = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % 6;
            resourcesCountToGenerate[resourceId]++;
        }

        for(uint256 i = 0; i < resourcesCountToGenerate.length; i++) {
            if (resourcesCountToGenerate[i] > 0) {
                resourceContract.mint(msg.sender, i, resourcesCountToGenerate[i]);
            }
        }

        return resourcesCountToGenerate;
    }

    /// @notice Sets the address of the ResourceNFT1155 contract
    /// @dev Only callable by the contract owner
    /// @param _resourceContract The new address of the ResourceNFT1155 contract
    function setResourceContract(address _resourceContract) external onlyOwner {
        resourceContract = ResourceNFT1155(_resourceContract);
    }

    /// @notice Sets the number of resources generated per search
    /// @dev Only callable by the contract owner
    /// @param _resourcesPerSearch The new number of resources per search
    function setResourcesPerSearch(uint256 _resourcesPerSearch) external onlyOwner {
        resourcesPerSearch = _resourcesPerSearch;
    }

    /// @notice Sets the cooldown time between resource searches
    /// @dev Only callable by the contract owner
    /// @param _resourceSearchCooldown The new cooldown time in seconds
    function setResourceSearchCooldown(uint256 _resourceSearchCooldown) external onlyOwner {
        resourceSearchCooldown = _resourceSearchCooldown;
    }
}
