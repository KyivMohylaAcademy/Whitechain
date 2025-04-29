import { ethers } from "hardhat";
import { writeFileSync } from "fs";

async function main() {
  console.log("Deploying contracts...");

  // Отримання акаунтів
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with account:", deployer.address);

  // Розгортання реєстру голосувань
  const VotingRegistry = await ethers.getContractFactory("VotingRegistry");
  const votingRegistry = await VotingRegistry.deploy();
  await votingRegistry.waitForDeployment();
  const votingRegistryAddress = await votingRegistry.getAddress();
  console.log("VotingRegistry deployed to:", votingRegistryAddress);

  // Розгортання токена винагороди
  const ERC20VotingToken = await ethers.getContractFactory("ERC20VotingToken");
  const erc20VotingToken = await ERC20VotingToken.deploy("Voting Token", "VOTE");
  await erc20VotingToken.waitForDeployment();
  const erc20VotingTokenAddress = await erc20VotingToken.getAddress();
  console.log("ERC20VotingToken deployed to:", erc20VotingTokenAddress);

  // Розгортання маркетплейсу
  const tokenPrice = ethers.parseEther("0.001"); // 0.001 ETH за 1 токен
  const Marketplace = await ethers.getContractFactory("Marketplace");
  const marketplace = await Marketplace.deploy(erc20VotingTokenAddress, tokenPrice);
  await marketplace.waitForDeployment();
  const marketplaceAddress = await marketplace.getAddress();
  console.log("Marketplace deployed to:", marketplaceAddress);

  // Розгортання контракту голосування
  const VotingContract = await ethers.getContractFactory("VotingContract");
  const votingContract = await VotingContract.deploy(
    votingRegistryAddress,
    erc20VotingTokenAddress,
    marketplaceAddress
  );
  await votingContract.waitForDeployment();
  const votingContractAddress = await votingContract.getAddress();
  console.log("VotingContract deployed to:", votingContractAddress);

  // Налаштування токена
  await erc20VotingToken.setMarketplace(marketplaceAddress);
  await erc20VotingToken.setVotingContract(votingContractAddress);
  console.log("ERC20VotingToken configured");

  // Додавання контракту голосування до реєстру
  await votingRegistry.addVotingContract(votingContractAddress);
  console.log("VotingContract added to registry");

  // Збереження адрес контрактів у файл
  const deploymentInfo = {
    votingRegistry: votingRegistryAddress,
    erc20VotingToken: erc20VotingTokenAddress,
    marketplace: marketplaceAddress,
    votingContract: votingContractAddress,
    network: (await ethers.provider.getNetwork()).name,
    deployer: deployer.address,
    timestamp: new Date().toISOString()
  };

  writeFileSync(
    "deployment-info.json",
    JSON.stringify(deploymentInfo, null, 2)
  );
  console.log("Deployment info saved to deployment-info.json");
}

// Виконання основної функції та обробка помилок
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});