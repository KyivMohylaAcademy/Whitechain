import { ethers } from "hardhat";

async function main() {
  const voteId: number = 4;
  const voting = await ethers.getContractAt(
    "VotingContractNFTReward",
    "0x11781Bff3e10D817202fA58E4aD3e7a3fdc775E9"
  );

  const options: string[] = await voting.getOptions(voteId);
  const results: bigint[] = await voting.getResults(voteId);

  console.log(`📊 Results for vote ${voteId}:`);
  for (let i = 0; i < options.length; i++) {
    console.log(`- ${options[i]}: ${results[i].toString()} vote(s)`);
  }
}

main().catch((error: Error) => {
  console.error(error);
  process.exitCode = 1;
});