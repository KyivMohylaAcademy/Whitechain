// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.24;

import '@openzeppelin/contracts/utils/Context.sol';

/// @title Voting Registry
/// @author Artem Tarasenko (@shabashab)
/// @notice Manages registration and tracking of voting contracts and their associated voting IDs.
contract VotingRegistry is Context {
  /// @notice List of all registered voting contract addresses.
  address[] public votingContracts;

  /// @dev Maps voting contract address to its owner. Is also used to check if the contract is registered.
  mapping(address => address) private _votingContractsOwners;
  /// @dev Maps voting contract address to array of its voting IDs.
  mapping(address => uint256[]) private _votingContractsVotings;

  /// @notice Thrown when trying to register a contract that is already registered.
  error ContractAlreadyRegistered();
  /// @notice Thrown when trying to interact with a contract that is not registered.
  error ContractNotRegistered();
  /// @notice Thrown when the caller does not have permission to perform an action.
  error Forbidden();

  /// @notice Checks if a voting contract is registered.
  /// @param contractAddress The address of the voting contract.
  /// @return True if the contract is registered, false otherwise.
  function isVotingContractRegistered(address contractAddress) public view returns (bool) {
    return _votingContractRegistered(contractAddress);
  }

  /// @notice Registers a new voting contract.
  /// @dev The sender becomes the owner of the registered voting contract.
  /// @param contractAddress The address of the voting contract to register.
  /// @custom:error ContractAlreadyRegistered if the contract is already registered.
  function addVotingContract(address contractAddress) public {
    if (_votingContractRegistered(contractAddress)) {
      revert ContractAlreadyRegistered();
    }

    votingContracts.push(contractAddress);
    _votingContractsOwners[contractAddress] = _msgSender();
  }

  /// @notice Removes a voting contract from the registry.
  /// @dev Only the voting contract itself or its owner can remove it.
  /// @param contractAddress The address of the voting contract to remove.
  /// @custom:error ContractNotRegistered if the contract is not registered.
  /// @custom:error Forbidden if the caller is not the owner or the contract itself.
  function removeVotingContract(address contractAddress) onlyVotingContractOrOwner(contractAddress) public {
    _votingContractsOwners[contractAddress] = address(0);

    for (uint256 i = 0; i < votingContracts.length; i++) {
      if (votingContracts[i] == contractAddress) {
        votingContracts[i] = votingContracts[votingContracts.length - 1];
        votingContracts.pop();
        break;
      }
    }
  }

  /// @notice Adds a voting ID to a registered voting contract.
  /// @dev Only the voting contract itself or its owner can add a voting ID.
  /// @param contractAddress The address of the voting contract.
  /// @param votingId The ID of the voting to add.
  /// @custom:error ContractNotRegistered if the contract is not registered.
  /// @custom:error Forbidden if the caller is not the owner or the contract itself.
  function addVotingContractVoting(address contractAddress, uint256 votingId) onlyVotingContractOrOwner(contractAddress) public {
    _votingContractsVotings[contractAddress].push(votingId);
  }

  /// @notice Removes a voting ID from a registered voting contract.
  /// @dev Only the voting contract itself or its owner can remove a voting ID.
  /// @param contractAddress The address of the voting contract.
  /// @param votingId The ID of the voting to remove.
  /// @custom:error ContractNotRegistered if the contract is not registered.
  /// @custom:error Forbidden if the caller is not the owner or the contract itself.
  function removeVotingContractVoting(address contractAddress, uint256 votingId) onlyVotingContractOrOwner(contractAddress) public {
    uint256[] storage votings = _votingContractsVotings[contractAddress];

    for (uint256 i = 0; i < votings.length; i++) {
      if (votings[i] == votingId) {
        for (uint256 j = i; j < votings.length - 1; j++) {
          votings[j] = votings[j + 1];
        }
        votings.pop();
        break;
      }
    }
  }

  /// @notice Returns all voting IDs associated with a voting contract.
  /// @param contractAddress The address of the voting contract.
  /// @return Array of voting IDs.
  function getVotingContractVotings(address contractAddress) public view returns (uint256[] memory) {
    return _votingContractsVotings[contractAddress];
  }

  /// @notice Returns the number of voting IDs associated with a voting contract.
  /// @param contractAddress The address of the voting contract.
  /// @return The count of voting IDs.
  function getVotingContractVotingsCount(address contractAddress) public view returns (uint256) {
    return _votingContractsVotings[contractAddress].length;
  }

  /// @notice Returns a voting ID at a specific index for a voting contract.
  /// @param contractAddress The address of the voting contract.
  /// @param index The index in the array of voting IDs.
  /// @return The voting ID at the given index.
  /// @custom:error ContractNotRegistered if the index is out of bounds.
  function getVotingContractVotingByIndex(address contractAddress, uint256 index) public view returns (uint256) {
    if (index >= _votingContractsVotings[contractAddress].length) {
      revert ContractNotRegistered();
    }

    return _votingContractsVotings[contractAddress][index];
  }

  /// @dev Checks if a voting contract is registered.
  /// @param contractAddress The address of the voting contract.
  /// @return True if registered, false otherwise.
  function _votingContractRegistered(address contractAddress) internal view returns (bool) {
    return _votingContractsOwners[contractAddress] != address(0);
  }

  /// @notice Modifier to restrict access to only the voting contract itself or its owner.
  /// @param contractAddress The address of the voting contract.
  /// @custom:error ContractNotRegistered if the contract is not registered.
  /// @custom:error Forbidden if the caller is not the owner or the contract itself.
  modifier onlyVotingContractOrOwner(address contractAddress) {
    if (!_votingContractRegistered(contractAddress)) {
      revert ContractNotRegistered();
    }

    if (_msgSender() != contractAddress && _msgSender() != _votingContractsOwners[contractAddress]) {
      revert Forbidden();
    }

    _;
  }
}
