// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {Test} from "forge-std/Test.sol";

import {Deploy} from "../script/Deploy.s.sol";
import {ResourceNFT1155} from "../src/ResourceNFT1155.sol";
import {ItemNFT721} from "../src/ItemNFT721.sol";
import {MagicToken} from "../src/MagicToken.sol";
import {CraftingSearch} from "../src/CraftingSearch.sol";
import {Marketplace} from "../src/Marketplace.sol";

/// @title DeployScriptTest
/// @notice Exercises the Deploy.s.sol script locally to ensure wiring matches expectations.
contract DeployScriptTest is Test {
    Deploy private deployScript;
    uint256 private constant PRIVATE_KEY = 0xA11CE;
    address private admin;

    function setUp() public {
        deployScript = new Deploy();

        vm.setEnv("PRIVATE_KEY", vm.toString(PRIVATE_KEY));
        admin = vm.addr(PRIVATE_KEY);

        vm.deal(admin, 1 ether);
        vm.setNonce(admin, 0);
    }

    function test_run_deploys_and_configs_system() public {
        deployScript.run();

        address resAddr = vm.computeCreateAddress(admin, 0);
        address itemsAddr = vm.computeCreateAddress(admin, 1);
        address magicAddr = vm.computeCreateAddress(admin, 2);
        address csAddr = vm.computeCreateAddress(admin, 3);
        address mktAddr = vm.computeCreateAddress(admin, 4);

        ResourceNFT1155 res = ResourceNFT1155(resAddr);
        ItemNFT721 items = ItemNFT721(itemsAddr);
        MagicToken magic = MagicToken(magicAddr);
        CraftingSearch cs = CraftingSearch(csAddr);
        Marketplace mkt = Marketplace(mktAddr);

        // admin retains control over all contracts
        assertTrue(res.hasRole(res.DEFAULT_ADMIN_ROLE(), admin), "res admin role");
        assertTrue(items.hasRole(items.DEFAULT_ADMIN_ROLE(), admin), "items admin role");
        assertTrue(magic.hasRole(magic.DEFAULT_ADMIN_ROLE(), admin), "magic admin role");
        assertTrue(cs.hasRole(cs.DEFAULT_ADMIN_ROLE(), admin), "cs admin role");
        assertTrue(mkt.hasRole(mkt.DEFAULT_ADMIN_ROLE(), admin), "mkt admin role");

        // cross-contract permissions mirror the script intent
        assertTrue(res.hasRole(res.MINTER_ROLE(), address(cs)), "res minter role");
        assertTrue(res.hasRole(res.BURNER_ROLE(), address(cs)), "res burner role");
        assertTrue(items.hasRole(items.MINTER_ROLE(), address(cs)), "items minter role");
        assertTrue(items.hasRole(items.BURNER_ROLE(), address(mkt)), "items burner role");
        assertTrue(magic.hasRole(magic.MARKET_ROLE(), address(mkt)), "magic market role");

        // dependency wiring is correct
        assertEq(address(cs.resources()), resAddr, "crafting uses resources");
        assertEq(address(cs.items()), itemsAddr, "crafting uses items");
        assertEq(address(mkt.items()), itemsAddr, "marketplace uses items");
        assertEq(address(mkt.magic()), magicAddr, "marketplace uses magic");
    }
}

