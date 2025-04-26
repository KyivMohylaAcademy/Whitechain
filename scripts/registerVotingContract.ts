import { ethers } from "hardhat";

async function main() {
  const registry = await ethers.getContractAt(
    "VotingRegistry",
    "0xe999124667e94AAc413281CdBaB6c446c3e4A353"
  );

  const tx = await registry.registerVotingContract("0x11781Bff3e10D817202fA58E4aD3e7a3fdc775E9");
  await tx.wait();

  console.log("Voting contract registered!");
}

main().catch((error: Error) => {
  console.error(error);
  process.exitCode = 1;
});
