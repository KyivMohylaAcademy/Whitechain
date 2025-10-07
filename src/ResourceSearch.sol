pragma solidity ~0.8.24;

import "./Resource.sol";

contract ResourceSearch {

    uint64 public constant SEARCH_PERIOD_SECONDS = 60;
    uint8 public constant RESOURCES_FARMED_PER_SEARCH = 3;

    mapping(address user => uint256) private _lastTimeSearch;
    address private _resourceContract;
    constructor(address resourceContract) {
        _resourceContract = resourceContract;
    }
    /**
     * This implementation run search with a period .
     */
    function search() public {
        uint256 timePassed = calculateTimePassedSinceLastSearch();
        require(timePassed >= 60);

        uint256[] memory types;
        uint256[] memory values;
        (types, values) = getRandomResources(msg.sender, block.timestamp, block.prevrandao);
        Resource(_resourceContract).mintBatch(msg.sender, types, values);
        _lastTimeSearch[msg.sender] = block.timestamp;
     }

    function calculateTimePassedSinceLastSearch() public view returns (uint256) {
        // according to some research, block timestamp can not go backward, so it should be safe enough
        uint256 timeNow = block.timestamp;
        return timeNow - _lastTimeSearch[msg.sender];
    }

    /*
    * Returns array of uint256 with respective types and another array filled with once.
    * Safe solution would be to call oracle asking for random number, but it is probably expensive
    * (though can be made cheaper using value from the oracle only as a seed to internally implemented
    * crypto safe algo).
    * 
    * Here randomness is not secure fundamentally, and provided only for child example of the game.
    */
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