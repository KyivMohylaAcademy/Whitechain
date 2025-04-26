import { ethers } from "hardhat";

async function main() {
  // Get the VotingRegistry contract address (replace with actual deployed address)
  const votingRegistryAddress = "0xdB95A3EAC78c69ef2b0D2690988bA4EC5bE64ccB"; 
  const votingContractAddress = "0xAaf46691a6bAe3702D8764c978cfAFb4957d5021";

  // Get the deployer's account
  const [deployer] = await ethers.getSigners();
  console.log("Registering VotingContract in VotingRegistry with the account:", deployer.address);

  // Attach to the deployed VotingRegistry contract
  const VotingRegistry = await ethers.getContractFactory("VotingRegistry");
  const votingRegistry = VotingRegistry.attach(votingRegistryAddress);

  // Call registerVotingContract function to register the VotingContract
  const tx = await (votingRegistry as any).registerVotingContract(votingContractAddress);
  await tx.wait();

  console.log(`VotingContract ${votingContractAddress} successfully registered in VotingRegistry.`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
