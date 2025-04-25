import { ethers } from "hardhat";

async function main() {
    const votingContractAddress = "0x4d4095a559efbA88B1390bA47C2D247D0Eb30B73";
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
