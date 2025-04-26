import { ethers } from "hardhat";

async function main() {
    const votingContractAddress = "0x4d4095a559efbA88B1390bA47C2D247D0Eb30B73";
    const signer = (await ethers.getSigners())[0];
    const Voting = await ethers.getContractAt("VotingContractNFT", votingContractAddress, signer);

    const votingId = 0;
    const optionId = 1; // Наприклад, "Суші"

    const tx = await Voting.vote(votingId, optionId);
    await tx.wait();

    console.log("✅ Успішно проголосовано!");
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
