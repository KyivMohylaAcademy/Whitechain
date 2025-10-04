// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {BaseTest} from "./Base.t.sol";

contract ItemNFT721Test is BaseTest {
    function test_items_contract_supports_interface() public view {
        assertTrue(items.supportsInterface(0x80ac58cd), "Item contract does not support ERC721");
    }
}
