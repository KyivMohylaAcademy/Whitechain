import { ethers } from "hardhat";

async function main() {
    const nftAddress = "0xf574b1CF543138589e2530654F7e35A96c7a55bC";

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
