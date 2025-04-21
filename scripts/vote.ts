import { ethers } from "hardhat";

async function main() {
    const votingContractAddress = "0xf574b1CF543138589e2530654F7e35A96c7a55bC";
    const Voting = await ethers.getContractAt("VotingContractNFT", votingContractAddress);

    const votingId = 0; // ← Тепер точно правильний!
    const optionId = 1; // Наприклад, "Суші"

    const tx = await Voting.vote(votingId, optionId);
    await tx.wait();

    console.log("✅ Успішно проголосовано!");
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
