import { ethers } from "hardhat";

async function main() {
  // Already deployed RewardNFT address
  const rewardNFTAddress = "0xA9527780Bd01D5F417Aa56e72270bFD16F7bEB3F";

  // Deploy VotingRegistry
  const VotingRegistry = await ethers.getContractFactory("VotingRegistry");
  const registry = await VotingRegistry.deploy();
  await registry.deployed();
  const registryAddress = registry.address;
  console.log("VotingRegistry deployed to:", registryAddress);

  // Deploy VotingContractNFTReward
  const VotingContractNFTReward = await ethers.getContractFactory("VotingContractNFTReward");
  const votingContract = await VotingContractNFTReward.deploy(rewardNFTAddress, registryAddress);
  await votingContract.deployed();
  const votingAddress = votingContract.address;
  console.log("VotingContractNFTReward deployed to:", votingAddress);
}

main().catch((error: Error) => {
  console.error(error);
  process.exitCode = 1;
});
