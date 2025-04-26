import { ethers } from "hardhat";

async function main() {
    const NFT = await ethers.getContractFactory("MyVotingNFT");
    const nft = await NFT.deploy();

    await nft.waitForDeployment();

    const address = await nft.getAddress();
    console.log("NFT contract deployed to:", address);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
