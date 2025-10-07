pragma solidity ~0.8.24;

import "./Item.sol";
import "./MagicCoins.sol";

/// @title Marketplace Contract
/// @notice Facilitates buying and selling of in-game items using MagicCoins.
/// @dev Interacts with Item and MagicCoins contracts for ownership and payment handling.
contract Marketplace {

    /// @notice Address of the MagicCoins contract used for payments.
    address _magicCoinsContract;

    /// @notice Address of the Item contract representing tradeable items.
    address _itemContract;

    /// @notice Maps item IDs to their respective sale prices in MagicCoins.
    mapping(uint256 => uint256) itemsToSell;
    
    /// @notice Initializes the Marketplace with references to the MagicCoins and Item contracts.
    /// @param magicCoinsContract The address of the deployed MagicCoins contract.
    /// @param itemContract The address of the deployed Item contract.
    constructor (address magicCoinsContract, address itemContract) {
        _magicCoinsContract = magicCoinsContract;
        _itemContract = itemContract;
    }

    /// @notice Lists an owned item for sale on the marketplace with a specific price.
    /// @dev The caller must be the owner or approved operator of the item.
    /// @param itemId The ID of the item being listed for sale.
    /// @param magicTokensValue The price of the item in MagicCoins (must be non-zero).
    function putItemToSell(uint256 itemId, uint256 magicTokensValue) external {
        // we do not allow zero price, so we can derive status of the item as being for sale or not being for sale
        // i.e. having zero price (not being for sale), or having non-zero price (being for sale)
        // zero price 'sell' may be put into transfer mechanism with limitation of that we need to specify receiver
        require(magicTokensValue != 0);
        Item itemContract = Item(_itemContract);
        require(itemContract.ownerOf(itemId) == msg.sender || itemContract.getApproved(itemId) == msg.sender);
        itemsToSell[itemId] = magicTokensValue;
    }

    /// @notice Removes an item from sale on the marketplace.
    /// @dev The caller must be the owner or approved operator of the listed item.
    /// @param itemId The ID of the item to remove from sale.
    function removeItemFromSell(uint256 itemId) external {
        Item itemContract = Item(_itemContract);
        require(itemContract.ownerOf(itemId) == msg.sender || itemContract.getApproved(itemId) == msg.sender);
        delete itemsToSell[itemId];
    }

    /// @notice Purchases an item listed for sale, transferring ownership and payment.
    /// @dev Burns MagicCoins from the buyer, transfers the item, and mints MagicCoins to the seller.
    /// @param itemId The ID of the item to purchase.
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
