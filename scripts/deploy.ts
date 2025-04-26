import { ethers } from "hardhat";

async function main() {
  const RewardNFT = await ethers.getContractFactory("RewardNFT");
  const rewardNFT = await RewardNFT.deploy();

  await rewardNFT.deployed();

  console.log("RewardNFT deployed to:", rewardNFT.address);
}

main().catch((error: Error) => {
  console.error(error);
  process.exitCode = 1;
});
