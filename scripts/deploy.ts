import { ethers } from "hardhat";

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying with account:", deployer.address);

    const TokenFactory = await ethers.getContractFactory("ERC20VotingToken");
    const token = await TokenFactory.deploy();
    await token.waitForDeployment();
    const tokenAddress = await token.getAddress();
    console.log("ERC20VotingToken deployed to:", tokenAddress);

    const VotingFactory = await ethers.getContractFactory("VotingContractERC20");
    const voting = await VotingFactory.deploy(tokenAddress, 2, 7 * 24 * 60 * 60); // 7 days
    await voting.waitForDeployment();
    const votingAddress = await voting.getAddress();
    console.log("VotingContractERC20 deployed to:", votingAddress);

    const MarketplaceFactory = await ethers.getContractFactory("Marketplace");
    const marketplace = await MarketplaceFactory.deploy(tokenAddress);
    await marketplace.waitForDeployment();
    const marketplaceAddress = await marketplace.getAddress();
    console.log("Marketplace deployed to:", marketplaceAddress);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
