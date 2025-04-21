import { ethers } from "hardhat";

async function main() {
    const votingAddress = "0xda452E37256009f69291B6B414A9f4e234BCCcdc";
    const Voting = await ethers.getContractAt("VotingContractNFT", votingAddress);

    const votingId = 0;
    const voting = await Voting.votings(votingId);

    console.log("🔍 Назва голосування:", voting.title);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
