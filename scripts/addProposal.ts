import { ethers } from "hardhat";

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Running as:", deployer.address);

    const votingAddress = "0xd6e981C307D017EAAf7b6a7E90dF8ECbd53122e8";

    const VotingFactory = await ethers.getContractFactory("VotingContractERC20");
    const voting = VotingFactory.attach(votingAddress);

    const proposalText = "Work with Whitechain🚀";

    const tx = await voting.addProposal(proposalText);
    await tx.wait();

    console.log("Proposal is added:", proposalText);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
