import { ethers } from "hardhat";

async function main() {
    const votingContractAddress = "0x4d4095a559efbA88B1390bA47C2D247D0Eb30B73"; // адреса VotingContractNFT
    const Voting = await ethers.getContractAt("VotingContractNFT", votingContractAddress);

    const title = "Що їсти на обід?";
    const options = ["Піца", "Суші", "Борщ"];
    const durationSeconds = 3600; // 1 година

    const tx = await Voting.createVoting(title, options, durationSeconds);
    await tx.wait();

    console.log("Voting created successfully.");
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
