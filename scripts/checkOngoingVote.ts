import { ethers } from "hardhat";

async function main() {
  const voting = await ethers.getContractAt(
    "VotingContractNFTReward",
    "0x11781Bff3e10D817202fA58E4aD3e7a3fdc775E9"
  );

  const voteId: number = 4;
  const vote = await voting.votes(voteId);

  const endTime: number = Number(vote.endTime);
  const now: number = Math.floor(Date.now() / 1000);

  console.log("Vote ends at:", new Date(endTime * 1000).toISOString());
  console.log("Current time:", new Date(now * 1000).toISOString());

  if (now < endTime) {
    console.log("✅ Vote is still ongoing.");
  } else {
    console.log("🛑 Vote has ended.");
  }
}

main().catch((error: Error) => {
  console.error(error);
  process.exitCode = 1;
});