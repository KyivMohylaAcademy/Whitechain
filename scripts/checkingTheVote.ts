import { ethers } from "hardhat";


async function main() {
  const voting = await ethers.getContractAt(
    "VotingContractNFTReward",
    "0x11781Bff3e10D817202fA58E4aD3e7a3fdc775E9"
  );

  const options: string[] = await voting.getOptions(3);
  console.log("Options for voteId 3:", options);
}

main().catch((error: Error) => {
  console.error(error);
  process.exitCode = 1;
});