import { ethers } from "hardhat";

async function main() {
    const nftAddress = "0x2bC6F7E733152cA67C8acA82783cFd41e618e72D";

    const Voting = await ethers.getContractFactory("VotingContractNFT");
    const voting = await Voting.deploy(nftAddress); // ← передаємо NFT

    await voting.waitForDeployment();

    const address = await voting.getAddress();
    console.log("VotingContractNFT deployed to:", address);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
