// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./NFTContract.sol";

contract Marketplace {
    NFTContract public nftContract;

    constructor(address _nftContract) {
        nftContract = NFTContract(_nftContract);
    }

    // List an NFT for sale
    function listNFT(uint tokenId, uint price) external {
        nftContract.listToken(tokenId, price);
    }

    // Cancel a listing
    function cancelListing(uint tokenId) external {
        nftContract.cancelListing(tokenId);
    }

    // Buy an NFT
    function buyNFT(uint tokenId) external payable {
        nftContract.buyToken{value: msg.value}(tokenId);
    }

    // Check if NFT is listed
    function isListed(uint tokenId) external view returns (bool) {
        return nftContract.isListed(tokenId);
    }

    // Get price of a listed token
    function getListingPrice(uint tokenId) external view returns (uint) {
        (, uint price) = nftContract.listings(tokenId);
        return price;
    }
}
