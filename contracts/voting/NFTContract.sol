// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTContract is ERC721Enumerable, Ownable {
    uint public nextTokenId;

    struct Listing {
        address seller;
        uint price;
    }

    mapping(uint => Listing) public listings;

    constructor(address initialOwner) ERC721("VotingNFT", "VOTE") Ownable(initialOwner) {}

    // Owner-only mint
    function mint(address to) public onlyOwner {
        uint tokenId = nextTokenId++;
        _safeMint(to, tokenId);
    }

    // Owner-only burn
    function burn(address from) public onlyOwner {
        require(balanceOf(from) > 0, "No NFTs to burn.");
        uint tokenId = tokenOfOwnerByIndex(from, balanceOf(from) - 1);
        _burn(tokenId);
    }

    // List token for sale
    function listToken(uint tokenId, uint price) external {
        require(ownerOf(tokenId) == msg.sender, "Not the owner");
        require(price > 0, "Price must be positive");
        listings[tokenId] = Listing(msg.sender, price);
        approve(address(this), tokenId); // Allow contract to transfer on sale
    }

    // Cancel a listing
    function cancelListing(uint tokenId) external {
        require(listings[tokenId].seller == msg.sender, "Not the seller");
        delete listings[tokenId];
    }

    // Purchase a token
    function buyToken(uint tokenId) external payable {
        Listing memory item = listings[tokenId];
        require(item.price > 0, "Token not for sale");
        require(msg.value == item.price, "Incorrect value");

        address seller = item.seller;

        delete listings[tokenId];
        _transfer(seller, msg.sender, tokenId);
        payable(seller).transfer(msg.value);
    }

    // Check if token is listed
    function isListed(uint tokenId) external view returns (bool) {
        return listings[tokenId].price > 0;
    }
}
