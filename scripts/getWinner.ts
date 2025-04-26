import { ethers } from "hardhat";

async function main() {
    const votingContractAddress = "0x4d4095a559efbA88B1390bA47C2D247D0Eb30B73";
    const Voting = await ethers.getContractAt("VotingContractNFT", votingContractAddress);

    const votingId = 0; // якщо голосування одне

    const winner = await Voting.getWinner(votingId);
    console.log("🏆 Переможець:", winner);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
