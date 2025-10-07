pragma solidity ~0.8.24;

import "./Resource.sol";

/// @title Resource Search Contract
/// @notice Allows users to perform periodic searches to obtain random resources.
/// @dev Interacts with the Resource contract to mint resource tokens after each search.
contract ResourceSearch {

    /// @notice The minimum time in seconds required between two searches per user.
    uint64 public constant SEARCH_PERIOD_SECONDS = 60;

    /// @notice The number of resource units granted per search.
    uint8 public constant RESOURCES_FARMED_PER_SEARCH = 3;

    /// @notice Tracks the timestamp of the last search performed by each user.
    mapping(address user => uint256) private _lastTimeSearch;

    /// @notice The address of the Resource contract used to mint new resources.
    address private _resourceContract;

    /// @notice Initializes the ResourceSearch contract with the Resource contract reference.
    /// @param resourceContract The address of the deployed Resource contract.
    constructor(address resourceContract) {
        _resourceContract = resourceContract;
    }

    /// @notice Performs a search operation that grants random resources to the caller. Enforces a cooldown period between searches for each user.
    /// Generates pseudo-random resource types using block and sender data (not secure for production).
    function search() public {
        uint256 timePassed = calculateTimePassedSinceLastSearch();
        require(timePassed >= 60);

        uint256[] memory types;
        uint256[] memory values;
        (types, values) = getRandomResources(msg.sender, block.timestamp, block.prevrandao);
        Resource(_resourceContract).mintBatch(msg.sender, types, values);
        _lastTimeSearch[msg.sender] = block.timestamp;
     }

    /// @notice Calculates how many seconds have passed since the caller’s last search.
    /// @dev Relies on the assumption that block timestamps are monotonically increasing.
    /// @return The number of seconds elapsed since the last search by the caller.
    function calculateTimePassedSinceLastSearch() public view returns (uint256) {
        // according to some research, block timestamp can not go backward, so it should be safe enough
        uint256 timeNow = block.timestamp;
        return timeNow - _lastTimeSearch[msg.sender];
    }

    /// @notice Generates pseudo-random resource types and quantities for a search.
    /// @dev This function is not cryptographically secure and should only be used for demo or test purposes.
    /// @param sender The address of the user performing the search.
    /// @param timestamp The current block timestamp used as part of the randomness seed.
    /// @param blockPrevrandao The previous randomness value of the block used as part of the randomness seed.
    /// @return types An array of generated resource type IDs.
    /// @return values An array of corresponding resource quantities (fixed to 1 per type).
    function getRandomResources(address sender, uint256 timestamp, uint256 blockPrevrandao) internal pure returns (uint256[] memory, uint256[] memory) {
        uint256[] memory types = new uint256[](RESOURCES_FARMED_PER_SEARCH);
        uint256[] memory values = new uint256[](RESOURCES_FARMED_PER_SEARCH);
        for(uint i=0; i<RESOURCES_FARMED_PER_SEARCH; i++) {
            // NOT SECURE, CAN BE CALCULATED
            uint256 pseudoRandomNumber = uint256(keccak256(abi.encodePacked(timestamp, sender, blockPrevrandao, i)));
            types[i] = pseudoRandomNumber % (uint256(type(Resource.Type).max) + 1);
            values[i] = 1;
        }
        
        return (types, values); 
    }
}
