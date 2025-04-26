import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const MY_WALLET_PUBLIC_KEY = "0xBA6c754F59336e8fA00a2a2d6697191DbdD11d4E";

const NFTContractModule = buildModule("NFTContractModule", (m) => {
  const initialOwner = m.getParameter("initialOwner", MY_WALLET_PUBLIC_KEY);

  const nftContract = m.contract("NFTContract", [initialOwner]);

  return { nftContract };
});

export default NFTContractModule;
