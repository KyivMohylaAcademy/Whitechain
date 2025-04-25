// This setup uses Hardhat Ignition to manage smart contract deployments.
// Learn more about it at https://hardhat.org/ignition

import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import { keccak256, toBytes } from "viem";

const CraftingModule = buildModule("CraftingModule", (m) => {
  const MINTER_ROLE = keccak256(toBytes("MINTER_ROLE"))
  const BURNER_ROLE = keccak256(toBytes("BURNER_ROLE"))

  const gameItemContract = m.contract("GameItemNFT721")
  const resourceContract = m.contract("ResourceNFT1155")
  const magicTokenContract = m.contract("MagicToken")

  const craftingContract = m.contract("ResourceCrafting", [resourceContract, gameItemContract])
  const searchContract = m.contract("ResourceSearch", [resourceContract])
  const marketplaceContract = m.contract("GameItemsMarketplace", [gameItemContract, magicTokenContract])

  m.call(resourceContract, "grantRole", [MINTER_ROLE, searchContract], { id: "grantResourceMinterToSearch" });
  m.call(resourceContract, "grantRole", [BURNER_ROLE, craftingContract], { id: "grantResourceBurnerToCrafting" });
  m.call(gameItemContract, "grantRole", [MINTER_ROLE, craftingContract], { id: "grantGameItemMinterToCrafting" });
  m.call(gameItemContract, "grantRole", [BURNER_ROLE, marketplaceContract], { id: "grantGameItemBurnerToMarketplace" });

  return {
    gameItemContract,
    resourceContract,
    magicTokenContract,
    craftingContract,
    searchContract,
    marketplaceContract,
  }
});

export default CraftingModule;
