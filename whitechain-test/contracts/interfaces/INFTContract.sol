// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface INFTContract is IERC721 {
    function mintReward(address to) external returns (uint256);
    function burn(uint256 tokenId) external;
}