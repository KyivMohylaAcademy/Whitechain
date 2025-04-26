import { ethers } from "hardhat";

async function main() {
    const nftAddress = "0xf574b1CF543138589e2530654F7e35A96c7a55bC";
    const to = "0x209a8aC17358aBE1b2f8193DddF7116dFB05c026";
    const tokenURI = "https://example.com/metadata.json"; // може бути будь-що

    const NFT = await ethers.getContractAt("MyVotingNFT", nftAddress);
    const tx = await NFT.mint(to, tokenURI);

    await tx.wait();
    console.log("NFT minted to:", to);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
