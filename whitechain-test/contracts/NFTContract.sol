// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title NFT Contract for Voting Rewards
 * @notice NFT контракт для винагород за голосування
 */

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/INFTContract.sol";

contract NFTContract is ERC721URIStorage, Ownable, INFTContract {
    uint256 private _nextTokenId = 1;
    
    mapping(address => bool) private _minters;
    
    string public baseTokenURI;
    
    address private _marketplace;
    
    event NFTMinted(address indexed to, uint256 tokenId);
    event NFTBurned(uint256 tokenId);
    event MinterAdded(address indexed minter);
    event MinterRemoved(address indexed minter);
    event MarketplaceUpdated(address indexed marketplace);
    
    constructor(string memory name, string memory symbol, string memory _baseTokenURI) ERC721(name, symbol) Ownable(msg.sender) {
        baseTokenURI = _baseTokenURI;
    }
    
    /**
     * @notice Встановити адресу маркетплейсу
     * @param marketplace Адреса маркетплейсу
     */
    function setMarketplace(address marketplace) external onlyOwner {
        _marketplace = marketplace;
        emit MarketplaceUpdated(marketplace);
    }
    
    /**
     * @notice Додати мінтера
     * @param minter Адреса мінтера
     */
    function addMinter(address minter) external onlyOwner {
        _minters[minter] = true;
        emit MinterAdded(minter);
    }
    
    /**
     * @notice Видалити мінтера
     * @param minter Адреса мінтера
     */
    function removeMinter(address minter) external onlyOwner {
        _minters[minter] = false;
        emit MinterRemoved(minter);
    }
    
    /**
     * @notice Перевірити чи є адреса мінтером
     * @param minter Адреса для перевірки
     */
    function isMinter(address minter) public view returns (bool) {
        return _minters[minter];
    }
    
    /**
     * @notice Мінт NFT як винагороду за голосування
     * @param to Адреса отримувача
     */
    function mintReward(address to) external override returns (uint256) {
        require(_minters[msg.sender], "Not authorized to mint");
        
        uint256 newTokenId = _nextTokenId++;
        
        _mint(to, newTokenId);
        
        _setTokenURI(newTokenId, string.concat(baseTokenURI, "/", _toString(newTokenId)));
        
        emit NFTMinted(to, newTokenId);
        
        return newTokenId;
    }
    
    /**
     * @notice Спалити NFT (використовується при продажу на маркетплейсі)
     * @param tokenId ID токена для спалювання
     */
    function burn(uint256 tokenId) external override {
        require(msg.sender == _marketplace, "Only marketplace can burn");
        
        try this.ownerOf(tokenId) returns (address) {
            _burn(tokenId);
            emit NFTBurned(tokenId);
        } catch {
            revert("Token does not exist");
        }
    }
    
    /**
     * @notice Встановити базовий URI для метаданих
     * @param _baseTokenURI Новий базовий URI
     */
    function setBaseURI(string memory _baseTokenURI) external onlyOwner {
        baseTokenURI = _baseTokenURI;
    }
    
    /**
     * @notice Отримати загальну кількість викарбуваних NFT
     */
    function getTotalSupply() external view returns (uint256) {
        return _nextTokenId - 1;
    }
    
    /**
     * @notice Допоміжна функція для перетворення uint256 в string
     */
    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        
        uint256 temp = value;
        uint256 digits;
        
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        
        bytes memory buffer = new bytes(digits);
        
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        
        return string(buffer);
    }
}