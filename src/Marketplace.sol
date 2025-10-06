pragma solidity ~0.8.25;

import "./Item.sol";
import "./MagicCoins.sol";

contract Marketplace {

    address _magicCoinsContract;
    address _itemContract;

    mapping(uint256 => uint256) itemsToSell;
    
    constructor (address magicCoinsContract, address itemContract) {
        _magicCoinsContract = magicCoinsContract;
        _itemContract = itemContract;
    }

    function putItemToSell(uint256 itemId, uint256 magicTokensValue) external {
        // we do not allow zero price, so we can derive status of the item as being for sale or not being for sale
        // i.e. having zero price (not being for sale), or having non-zero price (being for sale)
        // zero price 'sell' may be put into transfer mechanism with limitation of that we need to specify receiver
        require(magicTokensValue != 0);
        Item itemContract = Item(_itemContract);
        require(itemContract.ownerOf(itemId) == msg.sender || itemContract.getApproved(itemId) == msg.sender);
        itemsToSell[itemId] = magicTokensValue;
    }

    function removeItemFromSell(uint256 itemId) external {
        Item itemContract = Item(_itemContract);
        require(itemContract.ownerOf(itemId) == msg.sender || itemContract.getApproved(itemId) == msg.sender);
        delete itemsToSell[itemId];
    }

    function buyItem(uint256 itemId) external {
        require(itemsToSell[itemId] != 0);

        Item itemContract = Item(_itemContract);
        address itemOwner = itemContract.ownerOf(itemId);
        address buyer = msg.sender;
        uint256 dealPrice = itemsToSell[itemId];

        MagicCoins magicCoinsContract = MagicCoins(_magicCoinsContract);
        magicCoinsContract.burn(msg.sender, dealPrice);
        itemContract.marketTransfer(itemOwner, buyer, itemId);
        magicCoinsContract.mint(itemOwner, dealPrice);
    }

}