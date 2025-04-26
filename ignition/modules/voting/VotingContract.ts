import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const MY_NFTCONTRACT_ADDRESS = "0x095405dC6Ec7f0918679a6Ee8Dd8214b67c3Cf09"

const VotingContractModule = buildModule("VotingContractModule", (m) => {
  const nftContractAddress = m.getParameter("nftContractAddress", MY_NFTCONTRACT_ADDRESS); // address of deployed NFT contract
  const startTime = m.getParameter("startTime", 1745942400); // e.g., block.timestamp + 60 (start in 1 min)
  const endTime = m.getParameter("endTime", 1745942400 + 86400*100); // e.g., block.timestamp + 3600 (1 hour voting)

  const votingContract = m.contract("VotingContract", [
    nftContractAddress,
    startTime,
    endTime,
  ]);

  return { votingContract };
});

export default VotingContractModule;
