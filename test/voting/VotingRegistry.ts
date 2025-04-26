import { expect } from "chai";
import { ethers } from "hardhat";
import { Signer, Contract } from "ethers";

describe("VotingRegistry", function () {
  let VotingRegistry: Contract;
  let votingRegistry: any;
  let owner: Signer;
  let addr1: Signer;
  let addr2: Signer;

  beforeEach(async () => {
    [owner, addr1, addr2] = await ethers.getSigners();
    const VotingRegistryFactory = await ethers.getContractFactory("VotingRegistry");
    votingRegistry = await VotingRegistryFactory.deploy();
    await votingRegistry.waitForDeployment();
  });

  it("should deploy VotingRegistry contract", async function () {
    expect(votingRegistry.address).to.not.be.null;
  });

  it("should set the deployer as the owner", async function () {
    const contractOwner = await votingRegistry.owner();
    expect(contractOwner).to.equal(await owner.getAddress());
  });

  it("should allow the owner to register a VotingContract", async function () {
    const votingContractAddress = "0x1234567890abcdef1234567890abcdef12345678";
    await votingRegistry.registerVotingContract(votingContractAddress);
    const isRegistered = await votingRegistry.registeredVotingContracts(votingContractAddress);
    expect(isRegistered).to.be.true;
  });

  it("should not allow non-owner to register a VotingContract", async function () {
    const votingContractAddress = "0x1234567890abcdef1234567890abcdef12345678";
    await expect(
      votingRegistry.connect(addr1).registerVotingContract(votingContractAddress)
    ).to.be.revertedWith("Only owner can modify the registry.");
  });

  it("should allow the owner to unregister a VotingContract", async function () {
    const votingContractAddress = "0x1234567890abcdef1234567890abcdef12345678";
    await votingRegistry.registerVotingContract(votingContractAddress);
    await votingRegistry.unregisterVotingContract(votingContractAddress);
    const isRegistered = await votingRegistry.registeredVotingContracts(votingContractAddress);
    expect(isRegistered).to.be.false;
  });

  it("should not allow non-owner to unregister a VotingContract", async function () {
    const votingContractAddress = "0x1234567890abcdef1234567890abcdef12345678";
    await votingRegistry.registerVotingContract(votingContractAddress);
    await expect(
      votingRegistry.connect(addr1).unregisterVotingContract(votingContractAddress)
    ).to.be.revertedWith("Only owner can modify the registry.");
  });

  it("should not allow registering an already registered VotingContract", async () => {
    const votingContractAddress = "0x1234567890abcdef1234567890abcdef12345678";
    await votingRegistry.registerVotingContract(votingContractAddress);
    await expect(
      votingRegistry.registerVotingContract(votingContractAddress)
    ).to.be.revertedWith("Contract is already registered.");
  });
  
  it("should not allow unregistering a contract that is not registered", async () => {
    const votingContractAddress = "0x1234567890abcdef1234567890abcdef12345678";
    await expect(
      votingRegistry.unregisterVotingContract(votingContractAddress)
    ).to.be.revertedWith("Contract not registered.");
  });

  it("should return all registered voting contracts", async () => {
    const address1 = "0x1111111111111111111111111111111111111111";
    const address2 = "0x2222222222222222222222222222222222222222";

    await votingRegistry.registerVotingContract(address1);
    await votingRegistry.registerVotingContract(address2);

    const contracts = await votingRegistry.getAllVotingContracts();
    expect(contracts).to.deep.equal([address1, address2]);

    // Test empty state after unregistration
    await votingRegistry.unregisterVotingContract(address1);
    const contractsAfterUnregister = await votingRegistry.getAllVotingContracts();
    expect(contractsAfterUnregister).to.deep.equal([address2]);
  });

  it("should return an empty array when no contracts are registered", async () => {
    const contracts = await votingRegistry.getAllVotingContracts();
    expect(contracts).to.deep.equal([]);
  });
  
  it("should return a single registered contract", async () => {
    const address1 = "0x1111111111111111111111111111111111111111";
    await votingRegistry.registerVotingContract(address1);
    
    const contracts = await votingRegistry.getAllVotingContracts();
    expect(contracts).to.deep.equal([address1]);
  });
  
  it("should update the list when a contract is unregistered", async () => {
    const address1 = "0x1111111111111111111111111111111111111111";
    await votingRegistry.registerVotingContract(address1);
    
    // Unregister and check the list is updated
    await votingRegistry.unregisterVotingContract(address1);
    const contractsAfterUnregister = await votingRegistry.getAllVotingContracts();
    expect(contractsAfterUnregister).to.deep.equal([]);
  });
  
});
