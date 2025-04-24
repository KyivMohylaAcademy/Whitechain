// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ResourceNFT1155.sol";

contract ResourceSearch is Ownable {
  error TooManyAttempts();

  uint256 public resourcesPerSearch = 3;
  uint256 public resourceSearchCooldown = 60 seconds;
  ResourceNFT1155 public resourceContract;

  mapping(address => uint256) public lastSearchedResources;

  constructor(
    address _resourceContract
  ) Ownable(_msgSender()) {
    resourceContract = ResourceNFT1155(_resourceContract);
  }

  function searchResources() external returns (uint256[] memory) {
    if(lastSearchedResources[msg.sender] + resourceSearchCooldown > block.timestamp) {
      revert TooManyAttempts();
    }

    // It is important that we keep the update here, because
    // minting calls onERC1155Received on receiveing smart contract
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

  function setResourceContract(address _resourceContract) external onlyOwner {
    resourceContract = ResourceNFT1155(_resourceContract);
  }

  function setResourcesPerSearch(uint256 _resourcesPerSearch) external onlyOwner {
    resourcesPerSearch = _resourcesPerSearch;
  }

  function setResourceSearchCooldown(uint256 _resourceSearchCooldown) external onlyOwner {
    resourceSearchCooldown = _resourceSearchCooldown;
  }
}