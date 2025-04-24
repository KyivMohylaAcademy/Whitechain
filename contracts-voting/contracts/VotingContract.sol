// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ERC20VotingToken.sol";
import "./VotingRegistry.sol";

contract VotingContract is Ownable {
  error VotingNotActive();
  error InsufficientVotingTokenBalance();
  error InvalidVotingVariantIndex();
  error NoActiveVoting();
  error ActiveVotingAlreadyExists();
  error InvalidVotingDataEndTime();
  error AlreadyVoted();
  error InvalidVotingIndex();

  uint256 public minimumVotingBalance;
  ERC20VotingToken public votingToken;
  VotingRegistry public votingRegistry;

  struct Voting {
    uint256 id;
    uint8 variantsCount;

    string title;
    string description;

    uint256 startTime;
    uint256 endTime;
  }

  struct VotingVariant {
    uint256 id;

    string title;
  }

  mapping(uint256 => Voting) public votings;
  mapping(uint256 => VotingVariant[]) public votingVariants;

  mapping(uint256 => mapping(address => bool)) public voted;
  mapping(uint256 => mapping(uint8 => uint256)) public votes;

  uint256 public votingsCount = 0;

  constructor(
    address _votingTokenAddress, 
    uint256 _initialMinimumVotingBalance,
    address _votingRegistry
  ) Ownable(_msgSender()) {
    votingToken = ERC20VotingToken(_votingTokenAddress);
    minimumVotingBalance = _initialMinimumVotingBalance;
    votingRegistry = VotingRegistry(_votingRegistry);
  }

  function setMinimumVotingBalance(uint256 _minimumVotingBalance) external onlyOwner {
    minimumVotingBalance = _minimumVotingBalance;
  }

  function addVoting(
    string memory _title,
    string memory _description,
    string[] memory _variants,
    uint256 _endTime
  ) external onlyOwner onlyVotingContractRegistered {
    if (votingsCount > 0 && votings[votingsCount - 1].endTime > block.timestamp) {
      revert ActiveVotingAlreadyExists();
    }

    if(_endTime < block.timestamp) {
      revert InvalidVotingDataEndTime();
    }

    if(_endTime - block.timestamp < 5 days) {
      revert InvalidVotingDataEndTime();
    }

    Voting storage newVoting = votings[votingsCount];

    newVoting.id = votingsCount;
    newVoting.variantsCount = uint8(_variants.length);

    newVoting.title = _title;
    newVoting.description = _description;

    newVoting.startTime = block.timestamp;
    newVoting.endTime = _endTime;

    for (uint i = 0; i < _variants.length; i++) {
      votingVariants[votingsCount].push(
        VotingVariant({
          id: i,
          title: _variants[i]
        })
      );
    }

    votingRegistry.addVotingContractVoting(address(this), votingsCount);
    votingsCount++;
  }

  function vote(uint256 votingId, uint8 variantId) external onlyVotingContractRegistered {
    if (votingsCount == 0) {
      revert VotingNotActive();
    }

    Voting storage voting = _activeVoting();

    if (votingId != voting.id) {
      revert VotingNotActive();
    }

    if (variantId >= voting.variantsCount) {
      revert InvalidVotingVariantIndex();
    }

    if (voted[votingId][msg.sender]) {
      revert AlreadyVoted();
    }

    if (votingToken.balanceOf(msg.sender) < minimumVotingBalance) {
      revert InsufficientVotingTokenBalance();
    }

    voted[votingId][msg.sender] = true;
    votes[votingId][variantId]++;
  }

  function activeVoting() external view returns (Voting memory) {
    return _activeVoting();
  }

  function activeVotingVariants() external view returns (VotingVariant[] memory) {
    Voting storage lastVoting = _activeVoting();

    return votingVariants[lastVoting.id];
  }

  function getVotingOutcome(uint256 votingId) external view returns (VotingVariant memory) {
    if(votingId >= votingsCount) {
      revert InvalidVotingIndex();
    }

    Voting storage voting = votings[votingId];

    uint8 winningVariantId = 0;

    for (uint8 i = 0; i < voting.variantsCount; i++) {
      if(votes[votingId][i] > votes[votingId][winningVariantId]) {
        winningVariantId = i;
      }
    }

    return votingVariants[votingId][winningVariantId];
  }

  function _activeVoting() internal view returns (Voting storage)  {
    if (votingsCount == 0) {
      revert NoActiveVoting();
    }

    Voting storage lastVoting = votings[votingsCount - 1];

    if (lastVoting.endTime < block.timestamp) {
      revert NoActiveVoting();
    }

    return lastVoting;
  }

  modifier onlyVotingContractRegistered() {
    if(!votingRegistry.isVotingContractRegistered(address(this))) {
      revert VotingRegistry.ContractNotRegistered();
    }
    _;
  }
}