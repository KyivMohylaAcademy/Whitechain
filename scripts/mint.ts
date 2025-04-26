import { ethers } from "hardhat";

async function main() {
  const contractAddress = "0xA9527780Bd01D5F417Aa56e72270bFD16F7bEB3F"; // Your deployed contract
  const rewardNFT = await ethers.getContractAt("RewardNFT", contractAddress);

  const recipient = "0x68bBe298aC55737FFe7CAF717100B47F29EB991B"; // Replace with your MetaMask address

  const tx = await rewardNFT.mint(recipient);
  await tx.wait();

  console.log("NFT minted to:", recipient);
}

main().catch((error: Error) => {
  console.error(error);
  process.exitCode = 1;
});
