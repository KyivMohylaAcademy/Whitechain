// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {BaseTest} from "./Base.t.sol";

/**
 * @title ResourceNFT1155Test
 * @notice Tests ERC1155 interface support on the resource contract.
 */
contract CraftingSearch is BaseTest {
    /// @notice Ensures the resource contract reports support for the ERC1155 interface ID.
    function test_resources_contract_supports_interface() public view {
        assertTrue(res.supportsInterface(0xd9b67a26), "Resource contract does not support ERC1155");
    }
}
