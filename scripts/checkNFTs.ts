import { ethers } from "hardhat";

async function main() {
  const [signer] = await ethers.getSigners();
  const userAddress = await signer.getAddress();
  const nftAddress = "0xA9527780Bd01D5F417Aa56e72270bFD16F7bEB3F"; // RewardNFT address

  const abi = [
    "function balanceOf(address owner) view returns (uint256)",
  ];

  const nft = await ethers.getContractAt(abi, nftAddress);

  const balance = await nft.balanceOf(userAddress);
  console.log(`You own ${balance.toString()} NFTs from RewardNFT`);

}

main().catch((error: Error) => {
  console.error(error);
  process.exitCode = 1;
});
