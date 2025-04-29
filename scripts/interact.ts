import { ethers } from "hardhat";
import * as fs from "fs";
import * as readline from "readline";

// Функція для читання з консолі
function createInterface() {
  return readline.createInterface({
    input: process.stdin,
    output: process.stdout
  });
}

// Функція для очікування введення користувача
async function question(rl: readline.Interface, query: string): Promise<string> {
  return new Promise((resolve) => {
    rl.question(query, (answer) => {
      resolve(answer);
    });
  });
}

// Функція для завантаження адрес контрактів
function loadDeploymentInfo() {
  try {
    const data = fs.readFileSync("deployment-info.json", "utf8");
    return JSON.parse(data);
  } catch (error) {
    console.error("Error loading deployment info:", error);
    process.exit(1);
  }
}

// Головна функція
async function main() {
  const deploymentInfo = loadDeploymentInfo();
  console.log("Loaded deployment info from network:", deploymentInfo.network);
  
  // Отримання екземплярів контрактів
  const votingRegistry = await ethers.getContractAt("VotingRegistry", deploymentInfo.votingRegistry);
  const erc20VotingToken = await ethers.getContractAt("ERC20VotingToken", deploymentInfo.erc20VotingToken);
  const marketplace = await ethers.getContractAt("Marketplace", deploymentInfo.marketplace);
  const votingContract = await ethers.getContractAt("VotingContract", deploymentInfo.votingContract);
  
  console.log(`
  Contract Addresses:
  - VotingRegistry: ${await votingRegistry.getAddress()}
  - ERC20VotingToken: ${await erc20VotingToken.getAddress()}
  - Marketplace: ${await marketplace.getAddress()}
  - VotingContract: ${await votingContract.getAddress()}
  `);
  
  const rl = createInterface();
  
  while (true) {
    console.log(`
    Available Actions:
    1. Create a new voting
    2. Vote in a voting
    3. Check voting results
    4. Buy ERC20 tokens
    5. Check token balance
    6. Sell ERC20 tokens
    7. Check voting info
    8. Exit
    `);
    
    const choice = await question(rl, "Enter your choice (1-8): ");
    
    switch (choice) {
      case "1": // Create a new voting
        await createVoting(rl, votingContract);
        break;
      case "2": // Vote in a voting
        await vote(rl, votingContract);
        break;
      case "3": // Check voting results
        await checkResults(rl, votingContract);
        break;
      case "4": // Buy ERC20 tokens
        await buyTokens(rl, marketplace);
        break;
      case "5": // Check token balance
        await checkBalance(rl, erc20VotingToken);
        break;
      case "6": // Sell ERC20 tokens
        await sellTokens(rl, marketplace, erc20VotingToken);
        break;
      case "7": // Check voting info
        await checkVotingInfo(rl, votingContract);
        break;
      case "8": // Exit
        console.log("Exiting...");
        rl.close();
        return;
      default:
        console.log("Invalid choice, please try again.");
    }
  }
}

// Функція для створення нового голосування
async function createVoting(rl: readline.Interface, votingContract: any) {
  const title = await question(rl, "Enter voting title: ");
  const description = await question(rl, "Enter voting description: ");
  
  const now = Math.floor(Date.now() / 1000);
  const startTimeStr = await question(rl, `Enter start time (seconds from now, default 60): `);
  const startTime = now + (parseInt(startTimeStr) || 60);
  
  const durationStr = await question(rl, `Enter duration in seconds (default 3600 - 1 hour): `);
  const duration = parseInt(durationStr) || 3600;
  const endTime = startTime + duration;
  
  const optionsCountStr = await question(rl, "Enter number of voting options (default 2): ");
  const optionsCount = parseInt(optionsCountStr) || 2;
  
  const rewardAmountStr = await question(rl, "Enter reward amount in tokens (default 1): ");
  const rewardAmount = ethers.parseUnits(rewardAmountStr || "1", 18);
  
  try {
    const tx = await votingContract.createVoting(
      title,
      description,
      startTime,
      endTime,
      optionsCount,
      rewardAmount
    );
    
    console.log("Creating voting... Transaction hash:", tx.hash);
    const receipt = await tx.wait();
    
    const event = receipt?.logs.find(
      (log: any) => log.fragment?.name === "VotingCreated"
    );
    
    if (event) {
      const votingId = event.args[0];
      console.log(`Voting created successfully with ID: ${votingId}`);
    } else {
      console.log("Voting created, but couldn't retrieve the ID.");
    }
  } catch (error) {
    console.error("Error creating voting:", error);
  }
}

// Функція для голосування
async function vote(rl: readline.Interface, votingContract: any) {
  const votingIdStr = await question(rl, "Enter voting ID: ");
  const votingId = parseInt(votingIdStr);
  
  const optionStr = await question(rl, "Enter your vote option (0, 1, ...): ");
  const option = parseInt(optionStr);
  
  try {
    const tx = await votingContract.vote(votingId, option);
    console.log("Casting vote... Transaction hash:", tx.hash);
    await tx.wait();
    console.log("Vote cast successfully!");
  } catch (error) {
    console.error("Error casting vote:", error);
  }
}

// Функція для перевірки результатів голосування
async function checkResults(rl: readline.Interface, votingContract: any) {
  const votingIdStr = await question(rl, "Enter voting ID: ");
  const votingId = parseInt(votingIdStr);
  
  try {
    const votingInfo = await votingContract.getVotingInfo(votingId);
    const optionsCount = votingInfo[4];
    
    console.log("\nVoting Results:");
    for (let i = 0; i < optionsCount; i++) {
      const votes = await votingContract.getVotesForOption(votingId, i);
      console.log(`Option ${i}: ${votes} votes`);
    }
    
    // Перевірка, чи закінчилося голосування
    const endTime = votingInfo[3];
    const now = Math.floor(Date.now() / 1000);
    
    if (now > endTime) {
      const winner = await votingContract.getWinner(votingId);
      console.log(`\nWinning option: ${winner}`);
    } else {
      console.log(`\nVoting is still active and ends in ${endTime - now} seconds.`);
    }
  } catch (error) {
    console.error("Error checking results:", error);
  }
}

// Функція для купівлі токенів
async function buyTokens(rl: readline.Interface, marketplace: any) {
  const amountStr = await question(rl, "Enter amount of tokens to buy: ");
  const amount = ethers.parseUnits(amountStr, 18);
  
  try {
    const tokenPrice = await marketplace.tokenPrice();
    const cost = amount * tokenPrice / ethers.parseUnits("1", 18);
    
    console.log(`Buying ${amountStr} tokens will cost ${ethers.formatEther(cost)} ETH`);
    const confirm = await question(rl, "Confirm purchase? (y/n): ");
    
    if (confirm.toLowerCase() === 'y') {
      const tx = await marketplace.buyTokens(amount, { value: cost });
      console.log("Buying tokens... Transaction hash:", tx.hash);
      await tx.wait();
      console.log("Tokens purchased successfully!");
    } else {
      console.log("Purchase cancelled.");
    }
  } catch (error) {
    console.error("Error buying tokens:", error);
  }
}

// Функція для перевірки балансу токенів
async function checkBalance(rl: readline.Interface, token: any) {
  const addressStr = await question(rl, "Enter address to check (leave empty for your address): ");
  
  try {
    const address = addressStr || (await ethers.provider.getSigner()).address;
    const balance = await token.balanceOf(address);
    console.log(`Balance of ${address}: ${ethers.formatUnits(balance, 18)} tokens`);
  } catch (error) {
    console.error("Error checking balance:", error);
  }
}

// Функція для продажу токенів
async function sellTokens(rl: readline.Interface, marketplace: any, token: any) {
  const amountStr = await question(rl, "Enter amount of tokens to sell: ");
  const amount = ethers.parseUnits(amountStr, 18);
  
  try {
    const signerAddress = await (await ethers.provider.getSigner()).address;
    const balance = await token.balanceOf(signerAddress);
    
    if (balance < amount) {
      console.log(`Insufficient token balance. You have ${ethers.formatUnits(balance, 18)} tokens.`);
      return;
    }
    
    // Перевірка на наявність дозволу
    const allowance = await token.allowance(signerAddress, await marketplace.getAddress());
    if (allowance < amount) {
      console.log("Approving tokens for marketplace...");
      const approveTx = await token.approve(await marketplace.getAddress(), amount);
      await approveTx.wait();
      console.log("Tokens approved successfully!");
    }
    
    const tx = await marketplace.sellTokens(amount);
    console.log("Selling tokens... Transaction hash:", tx.hash);
    await tx.wait();
    console.log("Tokens sold successfully!");
  } catch (error) {
    console.error("Error selling tokens:", error);
  }
}

// Функція для перевірки інформації про голосування
async function checkVotingInfo(rl: readline.Interface, votingContract: any) {
  const votingIdStr = await question(rl, "Enter voting ID: ");
  const votingId = parseInt(votingIdStr);
  
  try {
    const votingInfo = await votingContract.getVotingInfo(votingId);
    const title = votingInfo[0];
    const description = votingInfo[1];
    const startTime = votingInfo[2];
    const endTime = votingInfo[3];
    const optionsCount = votingInfo[4];
    const isActive = votingInfo[5];
    
    const now = Math.floor(Date.now() / 1000);
    const status = now < startTime 
      ? "Not started yet" 
      : now > endTime 
        ? "Ended" 
        : "Active";
    
    console.log(`
    Voting Information:
    ID: ${votingId}
    Title: ${title}
    Description: ${description}
    Start Time: ${new Date(Number(startTime) * 1000).toLocaleString()}
    End Time: ${new Date(Number(endTime) * 1000).toLocaleString()}
    Number of Options: ${optionsCount}
    Status: ${status}
    Is Active in Contract: ${isActive}
    `);
  } catch (error) {
    console.error("Error checking voting info:", error);
  }
}

// Запуск основної функції
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});