import { ethers } from "hardhat";

async function main() {
    const votingAddress = "0x4d4095a559efbA88B1390bA47C2D247D0Eb30B73";
    const Voting = await ethers.getContractAt("VotingContractNFT", votingAddress);

    const votingId = 0;
    const voting = await Voting.votings(votingId);

    console.log("🔍 Назва голосування:", voting.title);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
