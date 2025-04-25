const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log(`Розгортаю контракти з аккаунту: ${deployer.address}`);
  
  console.log("Розгортаю NFT контракт...");
  const NFTContract = await hre.ethers.getContractFactory("NFTContract");
  const nftContract = await NFTContract.deploy(
    "RudVotingNFT",
    "RVNFT", 
    "https://metadata-server.example/api/token/" 
  );
  await nftContract.waitForDeployment();
  console.log(`NFTContract розгорнуто за адресою: ${await nftContract.getAddress()}`);
  
  console.log("Розгортаю Marketplace...");
  const Marketplace = await hre.ethers.getContractFactory("Marketplace");
  const marketplace = await Marketplace.deploy(
    await nftContract.getAddress(),
    hre.ethers.parseEther("0.01")
  );
  await marketplace.waitForDeployment();
  console.log(`Marketplace розгорнуто за адресою: ${await marketplace.getAddress()}`);
  
  const votingRegistryAddress = "0x649f5025a3DAd6A54bDD6999A25408DB27c7005f";
  console.log(`Використовую адресу VotingRegistry: ${votingRegistryAddress}`);
  

  console.log("Розгортаю VotingContract...");
  const VotingContract = await hre.ethers.getContractFactory("VotingContract");
  const votingContract = await VotingContract.deploy(
    votingRegistryAddress,
    await nftContract.getAddress()
  );
  await votingContract.waitForDeployment();
  console.log(`VotingContract розгорнуто за адресою: ${await votingContract.getAddress()}`);
  
  console.log("Налаштовую взаємодію між контрактами...");
  
  const tx1 = await nftContract.addMinter(await votingContract.getAddress());
  await tx1.wait();
  console.log("VotingContract додано як мінтер в NFTContract");
  
  const tx2 = await nftContract.setMarketplace(await marketplace.getAddress());
  await tx2.wait();
  console.log("Marketplace встановлено в NFTContract");
  

  console.log(`\nДля завершення налаштування потрібно викликати:\n
  1. VotingRegistry.addVotingContract(${await votingContract.getAddress()})\n`);
  

  console.log("\nРозгорнуті адреси контрактів:");
  console.log(`NFTContract: ${await nftContract.getAddress()}`);
  console.log(`Marketplace: ${await marketplace.getAddress()}`);
  console.log(`VotingContract: ${await votingContract.getAddress()}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });