import { ethers } from "hardhat";

async function main() {
  const nft = await ethers.getContractAt(
    "RewardNFT",
    "0xA9527780Bd01D5F417Aa56e72270bFD16F7bEB3F"
  );

  const tx = await nft.transferOwnership("0x11781Bff3e10D817202fA58E4aD3e7a3fdc775E9");
  await tx.wait();

  console.log("✅ NFT ownership transferred to VotingContractNFTReward!");
}

main().catch((err: Error) => {
  console.error(err);
  process.exitCode = 1;
});
