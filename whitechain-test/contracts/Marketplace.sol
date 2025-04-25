// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title Marketplace для NFT
 * @notice Маркетплейс для купівлі/продажу NFT
 */

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "./interfaces/INFTContract.sol";

contract Marketplace is Ownable, ReentrancyGuard {
    INFTContract public nftContract;
    
    uint256 public nftPrice;
    

    mapping(address => uint256) private _coinBalances;
    
    event NFTListed(uint256 indexed tokenId, address indexed seller, uint256 price);
    event NFTSold(uint256 indexed tokenId, address indexed seller, address indexed buyer, uint256 price);
    event CoinsAdded(address indexed account, uint256 amount);
    event CoinsRemoved(address indexed account, uint256 amount);
    
    constructor(address _nftContract, uint256 _nftPrice) Ownable(msg.sender) {
        nftContract = INFTContract(_nftContract);
        nftPrice = _nftPrice;
    }
    
    /**
     * @notice Додати коїни користувачу (адмін функція для тестування)
     * @param account Адреса користувача
     * @param amount Кількість коїнів
     */
    function addCoins(address account, uint256 amount) external onlyOwner {
        _coinBalances[account] += amount;
        emit CoinsAdded(account, amount);
    }
    
    /**
     * @notice Продати NFT (спалити його і отримати коїни)
     * @param tokenId ID токена для продажу
     */
    function sellNFT(uint256 tokenId) external nonReentrant {
        address seller = msg.sender;
        

        require(nftContract.ownerOf(tokenId) == seller, "Not token owner");
        
        require(nftContract.getApproved(tokenId) == address(this) || 
                nftContract.isApprovedForAll(seller, address(this)), 
                "Marketplace not approved");
        
        nftContract.burn(tokenId);
        
        _coinBalances[seller] += nftPrice;
        
        emit NFTSold(tokenId, seller, address(0), nftPrice);
    }
    
    /**
     * @notice Отримати баланс коїнів
     * @param account Адреса користувача
     */
    function coinBalanceOf(address account) external view returns (uint256) {
        return _coinBalances[account];
    }
    
    /**
     * @notice Встановити нову ціну NFT
     * @param _nftPrice Нова ціна NFT в wei
     */
    function setNFTPrice(uint256 _nftPrice) external onlyOwner {
        nftPrice = _nftPrice;
    }
}