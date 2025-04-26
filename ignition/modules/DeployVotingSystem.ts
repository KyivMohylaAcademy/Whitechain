import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

export default buildModule("DeployVotingSystem", (m) => {
  const nft = m.contractAt("RewardNFT", "0xA9527780Bd01D5F417Aa56e72270bFD16F7bEB3F"); // already deployed
  const registry = m.contractAt("VotingRegistry", "0xc7dED65c4F8DaBa852B5Db685FDc332d2b6349F9"); // put actual address here

  const voting = m.contract("VotingContractNFTReward", [nft, registry]);

  return { voting };
});
