const { ethers } = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(`Розгортаю VotingRegistry з аккаунту: ${deployer.address}`);
  
  const VotingRegistry = await ethers.getContractFactory("VotingRegistry");
  const votingRegistry = await VotingRegistry.deploy();
  await votingRegistry.waitForDeployment();
  
  const registryAddress = await votingRegistry.getAddress();
  console.log(`VotingRegistry розгорнуто за адресою: ${registryAddress}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });