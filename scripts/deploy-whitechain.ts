import { ethers } from "hardhat";
import { writeFileSync } from "fs";

/**
 * Скрипт для розгортання контрактів у мережі Whitechain Testnet
 */
async function main() {
  console.log("Deploying contracts to Whitechain Testnet...");

  // Отримання акаунтів
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with account:", deployer.address);
  const balance = await ethers.provider.getBalance(deployer.address);
  console.log("Account balance:", ethers.formatEther(balance), "WETH");

  // Розгортання реєстру голосувань
  console.log("Deploying VotingRegistry...");
  const VotingRegistry = await ethers.getContractFactory("VotingRegistry");
  const votingRegistry = await VotingRegistry.deploy();
  await votingRegistry.waitForDeployment();
  const votingRegistryAddress = await votingRegistry.getAddress();
  console.log("VotingRegistry deployed to:", votingRegistryAddress);

  // Розгортання токена винагороди
  console.log("Deploying ERC20VotingToken...");
  const ERC20VotingToken = await ethers.getContractFactory("ERC20VotingToken");
  const erc20VotingToken = await ERC20VotingToken.deploy("WhiteBIT Voting Token", "WBVT");
  await erc20VotingToken.waitForDeployment();
  const erc20VotingTokenAddress = await erc20VotingToken.getAddress();
  console.log("ERC20VotingToken deployed to:", erc20VotingTokenAddress);

  // Розгортання маркетплейсу
  console.log("Deploying Marketplace...");
  const tokenPrice = ethers.parseEther("0.001"); // 0.001 WETH за 1 токен
  const Marketplace = await ethers.getContractFactory("Marketplace");
  const marketplace = await Marketplace.deploy(erc20VotingTokenAddress, tokenPrice);
  await marketplace.waitForDeployment();
  const marketplaceAddress = await marketplace.getAddress();
  console.log("Marketplace deployed to:", marketplaceAddress);

  // Розгортання контракту голосування
  console.log("Deploying VotingContract...");
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
  console.log("Configuring ERC20VotingToken...");
  await erc20VotingToken.setMarketplace(marketplaceAddress);
  await erc20VotingToken.setVotingContract(votingContractAddress);
  console.log("ERC20VotingToken configured");

  // Додавання контракту голосування до реєстру
  console.log("Adding VotingContract to registry...");
  await votingRegistry.addVotingContract(votingContractAddress);
  console.log("VotingContract added to registry");

  // Створення тестового голосування
  console.log("Creating test voting...");
  const now = Math.floor(Date.now() / 1000);
  const startTime = now + 60; // Починається через 1 хвилину
  const endTime = startTime + 3600; // Триває 1 годину

  const tx = await votingContract.createVoting(
    "Test Voting on Whitechain",
    "This is a test voting for the WhiteBIT task",
    startTime,
    endTime,
    2, // Кількість варіантів
    ethers.parseUnits("1", 18) // 1 токен як винагорода
  );
  await tx.wait();
  console.log("Test voting created");

  // Збереження адрес контрактів у файл
  const deploymentInfo = {
    votingRegistry: votingRegistryAddress,
    erc20VotingToken: erc20VotingTokenAddress,
    marketplace: marketplaceAddress,
    votingContract: votingContractAddress,
    network: "whitechain",
    deployer: deployer.address,
    timestamp: new Date().toISOString()
  };

  writeFileSync(
    "whitechain-deployment-info.json",
    JSON.stringify(deploymentInfo, null, 2)
  );
  console.log("Deployment info saved to whitechain-deployment-info.json");

  // Інструкції для верифікації
  console.log("\nTo verify contracts on Whitechain explorer:");
  console.log(`npx hardhat verify --network whitechain ${votingRegistryAddress}`);
  console.log(`npx hardhat verify --network whitechain ${erc20VotingTokenAddress} "WhiteBIT Voting Token" "WBVT"`);
  console.log(`npx hardhat verify --network whitechain ${marketplaceAddress} ${erc20VotingTokenAddress} ${tokenPrice}`);
  console.log(`npx hardhat verify --network whitechain ${votingContractAddress} ${votingRegistryAddress} ${erc20VotingTokenAddress} ${marketplaceAddress}`);
}

// Виконання основної функції та обробка помилок
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});