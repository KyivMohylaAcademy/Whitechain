// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {BaseTest} from "./Base.t.sol";

/**
 * @title ItemNFT721Test
 * @notice Tests ERC721 interface support on the item contract.
 */
contract ItemNFT721Test is BaseTest {
    /// @notice Ensures the item contract reports support for the ERC721 interface ID.
    function test_items_contract_supports_interface() public view {
        assertTrue(items.supportsInterface(0x80ac58cd), "Item contract does not support ERC721");
    }
}
