import { expect } from "chai";
import { ethers } from "hardhat";
import { time } from "@nomicfoundation/hardhat-network-helpers";
import { Contract } from "ethers";

describe("Voting System", function () {
  // Змінні для зберігання екземплярів контрактів
  let votingRegistry: Contract;
  let erc20VotingToken: Contract;
  let marketplace: Contract;
  let votingContract: Contract;
  
  // Змінні для зберігання акаунтів
  let owner: any;
  let voter1: any;
  let voter2: any;
  let voter3: any;
  
  // Змінні для параметрів
  const tokenPrice = ethers.parseEther("0.001"); // 0.001 ETH за 1 токен
  
  beforeEach(async function () {
    // Отримання акаунтів
    [owner, voter1, voter2, voter3] = await ethers.getSigners();
    
    // Розгортання контрактів
    const VotingRegistry = await ethers.getContractFactory("VotingRegistry");
    votingRegistry = await VotingRegistry.deploy();
    
    const ERC20VotingToken = await ethers.getContractFactory("ERC20VotingToken");
    erc20VotingToken = await ERC20VotingToken.deploy("Voting Token", "VOTE");
    
    const Marketplace = await ethers.getContractFactory("Marketplace");
    marketplace = await Marketplace.deploy(await erc20VotingToken.getAddress(), tokenPrice);
    
    const VotingContract = await ethers.getContractFactory("VotingContract");
    votingContract = await VotingContract.deploy(
      await votingRegistry.getAddress(),
      await erc20VotingToken.getAddress(),
      await marketplace.getAddress()
    );
    
    // Налаштування токена
    await erc20VotingToken.setMarketplace(await marketplace.getAddress());
    await erc20VotingToken.setVotingContract(await votingContract.getAddress());
    
    // Додавання контракту голосування до реєстру
    await votingRegistry.addVotingContract(await votingContract.getAddress());
  });
  
  describe("VotingRegistry", function () {
    it("Should add a voting contract", async function () {
      const isActive = await votingRegistry.isContractActive(await votingContract.getAddress());
      expect(isActive).to.be.true;
    });
    
    it("Should remove a voting contract", async function () {
      await votingRegistry.removeVotingContract(await votingContract.getAddress());
      const isActive = await votingRegistry.isContractActive(await votingContract.getAddress());
      expect(isActive).to.be.false;
    });
  });
  
  describe("ERC20VotingToken", function () {
    it("Should have correct name and symbol", async function () {
      expect(await erc20VotingToken.name()).to.equal("Voting Token");
      expect(await erc20VotingToken.symbol()).to.equal("VOTE");
    });
    
    it("Should mint tokens through marketplace", async function () {
      const amount = ethers.parseUnits("10", 18);
      const cost = amount * tokenPrice / ethers.parseUnits("1", 18);
      
      await (marketplace.connect(voter3) as any).buyTokens(amount, { value: cost });
      
      expect(await erc20VotingToken.balanceOf(voter1.address)).to.equal(amount);
    });
  });
  
  describe("Marketplace", function () {
    it("Should allow buying tokens", async function () {
      const amount = ethers.parseUnits("10", 18);
      const cost = amount * tokenPrice / ethers.parseUnits("1", 18);
      
      await (marketplace.connect(voter3) as any).buyTokens(amount, { value: cost });
      
      expect(await erc20VotingToken.balanceOf(voter1.address)).to.equal(amount);
    });
    
    it("Should fail when not enough ETH", async function () {
      const amount = ethers.parseUnits("10", 18);
      const cost = amount * tokenPrice / ethers.parseUnits("1", 18);
      
      await expect(
        (marketplace.connect(voter3) as any).buyTokens(amount, { value: cost - 1n })
      ).to.be.revertedWith("Insufficient payment");
    });
  });
  
  describe("VotingContract", function () {
    let votingId: bigint;
    const startTime = BigInt(Math.floor(Date.now() / 1000) + 60); // Починається через 1 хвилину
    const endTime = startTime + 3600n; // Триває 1 годину
    
    beforeEach(async function () {
      // Створення голосування
      const tx = await votingContract.createVoting(
        "Test Voting",
        "This is a test voting",
        startTime,
        endTime,
        2, // Кількість варіантів
        ethers.parseUnits("1", 18) // 1 токен як винагорода
      );
      
      const receipt = await tx.wait();
      const event = receipt?.logs.find(
        (log: any) => log.fragment?.name === "VotingCreated"
      );
      
      votingId = event?.args[0] || 0n;
      
      // Купівля токенів для голосування
      const amount = ethers.parseUnits("10", 18);
      const cost = amount * tokenPrice / ethers.parseUnits("1", 18);
      
      await (marketplace.connect(voter3) as any).buyTokens(amount, { value: cost });
      await (marketplace.connect(voter3) as any).buyTokens(amount, { value: cost });
      await (marketplace.connect(voter3) as any).buyTokens(amount, { value: cost });
    });
    
    it("Should create a voting", async function () {
      const votingInfo = await votingContract.getVotingInfo(votingId);
      expect(votingInfo[0]).to.equal("Test Voting");
      expect(votingInfo[1]).to.equal("This is a test voting");
      expect(votingInfo[2]).to.equal(startTime);
      expect(votingInfo[3]).to.equal(endTime);
      expect(votingInfo[4]).to.equal(2n);
      expect(votingInfo[5]).to.be.true;
    });
    
    it("Should allow voting and give rewards", async function () {
      // Активація голосування
      await time.increaseTo(startTime + 10n);
      
      // Голосування учасниками
      await (votingContract.connect(voter1) as any).vote(votingId, 0);
      await (votingContract.connect(voter1) as any).vote(votingId, 1);
      await (votingContract.connect(voter1) as any).vote(votingId, 0);
      
      // Перевірка успішності голосування
      expect(await votingContract.hasVoted(votingId, voter1.address)).to.be.true;
      expect(await votingContract.hasVoted(votingId, voter2.address)).to.be.true;
      expect(await votingContract.hasVoted(votingId, voter3.address)).to.be.true;
      
      // Перевірка кількості голосів
      expect(await votingContract.getVotesForOption(votingId, 0)).to.equal(2n);
      expect(await votingContract.getVotesForOption(votingId, 1)).to.equal(1n);
      
      // Закінчення голосування
      await time.increaseTo(endTime + 10n);
      
      // Перевірка переможця
      expect(await votingContract.getWinner(votingId)).to.equal(0n);
    });
    
    it("Should not allow voting twice", async function () {
      // Активація голосування
      await time.increaseTo(startTime + 10n);
      
      // Перше голосування
      await (votingContract.connect(voter1) as any).vote(votingId, 0)
      
      // Друге голосування
      await expect(
        (votingContract.connect(voter1) as any).vote(votingId, 1)
      ).to.be.revertedWith("Already voted");
    });
    
    it("Should not allow voting after end time", async function () {
      // Перехід до завершення голосування
      await time.increaseTo(endTime + 10n);
      
      // Спроба голосування
      await expect(
        (votingContract.connect(voter1) as any).vote(votingId, 0)
      ).to.be.revertedWith("Voting has ended");
    });
    
    it("Should not allow voting before start time", async function () {
      // Спроба голосування до початку
      await expect(
        (votingContract as any).connect(voter1).vote(votingId, 0)
        ).to.be.revertedWith("Voting has not started yet");
    });
  });
});