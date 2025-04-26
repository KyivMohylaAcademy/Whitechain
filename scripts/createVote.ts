import { ethers } from "hardhat";

async function main() {
  const voting = await ethers.getContractAt(
    "VotingContractNFTReward",
    "0x11781Bff3e10D817202fA58E4aD3e7a3fdc775E9"
  );

  const tx = await voting.createVote(["1st", "2nd", "3rd", "4th", "5th", "6th"], 300);
  await tx.wait();

  console.log("Vote created!");
}

main().catch((error: Error) => {
  console.error(error);
  process.exitCode = 1;
});
