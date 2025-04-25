const hre = require("hardhat");

async function main() {
  const votingRegistryAddress = "0x649f5025a3DAd6A54bDD6999A25408DB27c7005f";
  const votingContractAddress = "0x12E6f3B29553C18B7C68bDd0c0098784b6695ab8";
  const network = hre.network.name;
  
  console.log(`Реєструю VotingContract у VotingRegistry в мережі ${network}...`);
  console.log(`VotingRegistry: ${votingRegistryAddress}`);
  console.log(`VotingContract: ${votingContractAddress}`);
  
  const VotingRegistry = await hre.ethers.getContractFactory("VotingRegistry");
  const votingRegistry = VotingRegistry.attach(votingRegistryAddress);
  
  const tx = await votingRegistry.addVotingContract(votingContractAddress);
  await tx.wait();
  
  console.log("VotingContract успішно зареєстровано в VotingRegistry!");
  
  const isRegistered = await votingRegistry.isVotingContractRegistered(votingContractAddress);
  console.log(`Перевірка реєстрації: ${isRegistered ? "Успішно" : "Помилка!"}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });