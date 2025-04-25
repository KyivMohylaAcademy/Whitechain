const { ethers } = require("hardhat");
async function main() {
    const votingContractAddress = "0x12E6f3B29553C18B7C68bDd0c0098784b6695ab8";

    const VotingContract = await ethers.getContractFactory("VotingContract");
    const votingContract = VotingContract.attach(votingContractAddress);

    console.log("Створюю тестове голосування...");
  
    const description = "Яка технологія найбільш перспективна?";
    const durationInMinutes = 5;
    const option1 = "Blockchain";
    const option2 = "AI";
  
    const tx = await votingContract.createVoting(
    description, 
    durationInMinutes, 
    option1, 
    option2
  );
  
  await tx.wait();
  
  const currentVotingId = await votingContract.getCurrentVotingId();
  const createdVotingId = parseInt(currentVotingId) - 1;  
  
  console.log(`Голосування успішно створено з ID: ${createdVotingId}`);
  console.log(`Опис: ${description}`);
  console.log(`Опція 1: ${option1}`);
  console.log(`Опція 2: ${option2}`);
  console.log(`Тривалість: ${durationInMinutes} хвилин`);
  
  const details = await votingContract.getVotingDetails(createdVotingId);
  console.log("\nДеталі голосування з блокчейну:");
  console.log(`Опис: ${details[0]}`);
  console.log(`Початок: ${new Date(Number(details[1]) * 1000).toISOString()}`);
  console.log(`Кінець: ${new Date(Number(details[2]) * 1000).toISOString()}`);
  console.log(`Опція 1: ${details[3]}`);
  console.log(`Опція 2: ${details[4]}`);
  console.log(`Активне: ${details[5]}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });