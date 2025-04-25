// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ERC20VotingToken.sol";
import "./VotingRegistry.sol";

/// @title Voting Contract
/// @author Your Name or Organization
/// @notice Enables creation and participation in on-chain votings with ERC20-based eligibility and registry verification
/// @dev Only registered contracts in VotingRegistry can create and run votings. Each voting requires a minimum token balance.
contract VotingContract is Ownable {
    /// @notice Thrown when there is no active voting or voting is not active for the requested action
    error VotingNotActive();
    /// @notice Thrown when the caller does not have enough voting tokens to participate
    error InsufficientVotingTokenBalance();
    /// @notice Thrown when the specified voting variant index does not exist
    error InvalidVotingVariantIndex();
    /// @notice Thrown when there is no currently active voting
    error NoActiveVoting();
    /// @notice Thrown when there is already an active voting and a new one cannot be started
    error ActiveVotingAlreadyExists();
    /// @notice Thrown when the voting end time is invalid (in the past or too soon)
    error InvalidVotingDataEndTime();
    /// @notice Thrown when the caller has already voted in the current voting
    error AlreadyVoted();
    /// @notice Thrown when the requested voting index does not exist
    error InvalidVotingIndex();

    /// @notice Minimum ERC20 token balance required to participate in votings
    uint256 public minimumVotingBalance;

    /// @notice ERC20 token contract used for voting eligibility
    ERC20VotingToken public votingToken;

    /// @notice Registry contract used to verify voting contract registration
    VotingRegistry public votingRegistry;

    /// @notice Struct representing a voting event
    /// @param id Voting identifier (incremental)
    /// @param variantsCount Number of variants/options to vote for
    /// @param title Voting title
    /// @param description Voting description
    /// @param startTime Voting start time (unix timestamp)
    /// @param endTime Voting end time (unix timestamp)
    struct Voting {
        uint256 id;
        uint8 variantsCount;
        string title;
        string description;
        uint256 startTime;
        uint256 endTime;
    }

    /// @notice Struct representing a voting variant/option
    /// @param id Variant identifier (index)
    /// @param title Variant title/label
    struct VotingVariant {
        uint256 id;
        string title;
    }

    /// @notice Mapping from voting id to Voting struct
    mapping(uint256 => Voting) public votings;
    /// @notice Mapping from voting id to array of VotingVariant structs
    mapping(uint256 => VotingVariant[]) public votingVariants;
    /// @notice Mapping of voting id and user address to whether the user has voted
    mapping(uint256 => mapping(address => bool)) public voted;
    /// @notice Mapping of voting id and variant id to number of votes received by that variant
    mapping(uint256 => mapping(uint8 => uint256)) public votes;

    /// @notice Total number of votings created
    uint256 public votingsCount = 0;

    /// @notice Deploys the voting contract and sets up the voting token, minimum balance, and registry
    /// @param _votingTokenAddress Address of the ERC20 voting token contract
    /// @param _initialMinimumVotingBalance Initial minimum voting token balance required to vote
    /// @param _votingRegistry Address of the VotingRegistry contract
    constructor(
        address _votingTokenAddress, 
        uint256 _initialMinimumVotingBalance,
        address _votingRegistry
    ) Ownable(_msgSender()) {
        votingToken = ERC20VotingToken(_votingTokenAddress);
        minimumVotingBalance = _initialMinimumVotingBalance;
        votingRegistry = VotingRegistry(_votingRegistry);
    }

    /// @notice Sets the minimum ERC20 token balance required to vote
    /// @dev Only callable by the contract owner
    /// @param _minimumVotingBalance The new minimum balance required
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

    /// @notice Cast a vote for a specific variant in the active voting
    /// @dev Only callable if the contract is registered and voting is active; user must not have already voted and must have enough tokens
    /// @param votingId The id of the voting to participate in
    /// @param variantId The variant index to vote for
    /// @custom:throws VotingNotActive if there is no active voting or votingId does not match
    /// @custom:throws InvalidVotingVariantIndex if the variantId does not exist
    /// @custom:throws AlreadyVoted if the user has already voted
    /// @custom:throws InsufficientVotingTokenBalance if the user does not meet the minimum balance
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

    /// @notice Returns the currently active voting (if any)
    /// @return The Voting struct of the currently active voting
    /// @custom:throws NoActiveVoting if there is no active voting
    function activeVoting() external view returns (Voting memory) {
        return _activeVoting();
    }

    /// @notice Returns all variants/options for the currently active voting
    /// @return Array of VotingVariant structs for the active voting
    function activeVotingVariants() external view returns (VotingVariant[] memory) {
        Voting storage lastVoting = _activeVoting();
        return votingVariants[lastVoting.id];
    }

    /// @notice Returns the winning variant of a completed voting by voting id
    /// @dev The variant with the most votes is returned
    /// @param votingId The id of the voting to get the outcome for
    /// @return The VotingVariant struct of the winning variant
    /// @custom:throws InvalidVotingIndex if votingId does not exist
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

    /// @notice Internal function to get the currently active voting
    /// @dev Reverts if there is no active voting
    /// @return lastVoting The Voting struct for the active voting
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

    /// @notice Modifier to restrict functions to only registered voting contracts
    /// @dev Checks registration in the VotingRegistry contract
    modifier onlyVotingContractRegistered() {
        if(!votingRegistry.isVotingContractRegistered(address(this))) {
            revert VotingRegistry.ContractNotRegistered();
        }
        _;
    }
}
