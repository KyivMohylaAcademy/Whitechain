import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const MY_NFTCONTRACT_ADDRESS = "0x095405dC6Ec7f0918679a6Ee8Dd8214b67c3Cf09"

const MarketplaceModule = buildModule("MarketplaceModule", (m) => {
  const nftContractAddress = m.getParameter("nftContractAddress", MY_NFTCONTRACT_ADDRESS);

  const marketplace = m.contract("Marketplace", [nftContractAddress]);

  return { marketplace };
});

export default MarketplaceModule;
