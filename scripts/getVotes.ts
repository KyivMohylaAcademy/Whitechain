import { ethers } from "hardhat";

async function main() {
    const votingContractAddress = "0xf574b1CF543138589e2530654F7e35A96c7a55bC";
    const Voting = await ethers.getContractAt("VotingContractNFT", votingContractAddress);

    const votingId = 0;

    const optionsCount = (await Voting.votings(votingId)).optionsCount;

    console.log(`📊 Голоси по кожній опції:`);

    for (let i = 0; i < optionsCount; i++) {
        const [optionText, voteCount] = await Voting.getOption(votingId, i);
        console.log(`  - ${optionText}: ${voteCount.toString()}`);
    }
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
