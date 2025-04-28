import { ethers } from "hardhat";

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Running as:", deployer.address);

    const tokenAddress = "0x5927A9ee0949d1a9ccb0C43Ebe3c8E50B76119D0";        // token contract
    const marketplaceAddress = "0x336D665EF7C180B05373fa3b5D68eaa60225eE70";  // marketplace contact

    const TokenFactory = await ethers.getContractFactory("ERC20VotingToken");
    const token = TokenFactory.attach(tokenAddress);

    const tx = await token.transferOwnership(marketplaceAddress);
    await tx.wait();

    console.log(`Ownership of ERC20VotingToken transferred to Marketplace at ${marketplaceAddress}`);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
