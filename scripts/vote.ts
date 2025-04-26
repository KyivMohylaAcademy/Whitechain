import { ethers } from "hardhat";

async function main() {
  const voting = await ethers.getContractAt(
    "VotingContractNFTReward",
    "0x11781Bff3e10D817202fA58E4aD3e7a3fdc775E9"
  );

  const voteId: number = 4;
  const optionIndex: number = 2;

  const tx = await voting.vote(voteId, optionIndex);
  await tx.wait();

  console.log("Voted! You should receive an NFT.");
}

main().catch((error: Error) => {
  console.error(error);
  process.exitCode = 1;
});