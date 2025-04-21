import { ethers } from "hardhat";

async function main() {
    const votingContractAddress = "0xf574b1CF543138589e2530654F7e35A96c7a55bC"; // як завжди :)
    const Voting = await ethers.getContractAt("VotingContractNFT", votingContractAddress);

    const votingId = 0; // якщо голосування одне

    const winner = await Voting.getWinner(votingId);
    console.log("🏆 Переможець:", winner);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
