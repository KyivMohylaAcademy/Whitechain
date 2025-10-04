// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {BaseTest} from "./Base.t.sol";

contract CraftingSearch is BaseTest {
    function test_resources_contract_supports_interface() public view {
        assertTrue(res.supportsInterface(0xd9b67a26), "Resource contract does not support ERC1155");
    }
}
