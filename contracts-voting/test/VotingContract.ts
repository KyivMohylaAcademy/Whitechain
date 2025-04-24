import { loadFixture, time } from "@nomicfoundation/hardhat-toolbox-viem/network-helpers";
import { expect } from "chai";
import hre from "hardhat";
import { parseEther } from "viem";

describe("VotingContract", function () {
  async function deployVotingContractFixture() {
    const [owner, user, other] = await hre.viem.getWalletClients();

    // Deploy token
    const token = await hre.viem.deployContract("ERC20VotingToken", [
      "VotingToken",
      "VOTE",
    ]);

    // 0.1 ETH / 1 VOTE
    const tokenPrice = 1n * (10n ** 17n);

    // Deploy marketplace
    const marketplace = await hre.viem.deployContract("ERC20VotingTokenMarketplace", [
      token.address,
      tokenPrice
    ]);

    // Deploy registry and register VotingContract
    const registry = await hre.viem.deployContract("VotingRegistry");
    // Deploy VotingContract
    const minBalance = parseEther("1");
    const votingContract = await hre.viem.deployContract("VotingContract", [
      token.address,
      minBalance,
      registry.address,
    ]);
    // Register voting contract in registry
    await registry.write.addVotingContract([votingContract.address], { account: owner.account });

    // Set VotingContract as minter/burner in token
    await token.write.setMarketplaceAddress([marketplace.address], { account: owner.account });

    const publicClient = await hre.viem.getPublicClient();

    return {
      token,
      tokenPrice,
      registry,
      votingContract,
      owner,
      user,
      other,
      minBalance,
      publicClient,
      marketplace,
    };
  }

  describe("Deployment", function () {
    it("should deploy and set correct addresses and minimum balance", async function () {
      const { votingContract, token, registry, minBalance } = await loadFixture(deployVotingContractFixture);
      expect((await votingContract.read.votingToken()).toLowerCase()).to.equal(token.address.toLowerCase());
      expect((await votingContract.read.votingRegistry()).toLowerCase()).to.equal(registry.address.toLowerCase());
      expect(await votingContract.read.minimumVotingBalance()).to.equal(minBalance);
    });
  });

  describe("setMinimumVotingBalance", function () {
    it("should allow owner to set minimum voting balance", async function () {
      const { votingContract, owner } = await loadFixture(deployVotingContractFixture);
      await votingContract.write.setMinimumVotingBalance([123n], { account: owner.account });
      expect(await votingContract.read.minimumVotingBalance()).to.equal(123n);
    });

    it("should revert if non-owner tries to set minimum voting balance", async function () {
      const { votingContract, user } = await loadFixture(deployVotingContractFixture);
      await expect(
        votingContract.write.setMinimumVotingBalance([123n], { account: user.account })
      ).to.be.rejectedWith("OwnableUnauthorizedAccount(\"0x70997970C51812dc3A010C7d01b50e0d17dc79C8\")");
    });
  });

  describe("addVoting", function () {
    async function setup() {
      const { votingContract, owner, registry } = await loadFixture(deployVotingContractFixture);
      return { votingContract, owner, registry };
    }

    it("should add a voting with valid parameters", async function () {
      const { votingContract, owner } = await setup();
      const now = await time.latest();
      const endTime = now + 6 * 24 * 60 * 60; // 6 days from now
      await votingContract.write.addVoting(
        ["Title", "Description", ["Yes", "No"], BigInt(endTime)],
        { account: owner.account }
      );
      const voting = await votingContract.read.votings([0n]) as any[];
      expect(voting[2]).to.equal("Title");
      expect(voting[1]).to.equal(2);
    });

    it("should revert if contract is not registered", async function () {
      const { votingContract, owner, registry } = await loadFixture(deployVotingContractFixture);
      // Unregister contract by removing it
      await registry.write.removeVotingContract([votingContract.address], { account: owner.account });
      const now = await time.latest();
      const endTime = now + 6 * 24 * 60 * 60;
      await expect(
        votingContract.write.addVoting(
          ["Title", "Description", ["Yes", "No"], BigInt(endTime)],
          { account: owner.account }
        )
      ).to.be.rejectedWith("ContractNotRegistered");
    });

    it("should revert if an active voting already exists", async function () {
      const { votingContract, owner } = await setup();
      const now = await time.latest();
      const endTime = now + 6 * 24 * 60 * 60;
      await votingContract.write.addVoting(
        ["Title", "Description", ["Yes", "No"], BigInt(endTime)],
        { account: owner.account }
      );
      await expect(
        votingContract.write.addVoting(
          ["Title2", "Description2", ["A", "B"], BigInt(endTime + 10000)],
          { account: owner.account }
        )
      ).to.be.rejectedWith("ActiveVotingAlreadyExists");
    });

    it("should revert if endTime is in the past", async function () {
      const { votingContract, owner } = await setup();
      const now = await time.latest();
      await expect(
        votingContract.write.addVoting(
          ["Title", "Description", ["Yes", "No"], BigInt(now - 1000)],
          { account: owner.account }
        )
      ).to.be.rejectedWith("InvalidVotingDataEndTime");
    });

    it("should revert if endTime is less than 5 days ahead", async function () {
      const { votingContract, owner } = await setup();
      const now = await time.latest();
      const endTime = now + 4 * 24 * 60 * 60; // 4 days from now
      await expect(
        votingContract.write.addVoting(
          ["Title", "Description", ["Yes", "No"], BigInt(endTime)],
          { account: owner.account }
        )
      ).to.be.rejectedWith("InvalidVotingDataEndTime");
    });
  });

  describe("vote", function () {
    async function setupWithActiveVoting() {
      const {
        votingContract,
        owner,
        user,
        other,
        token,
        tokenPrice,
        minBalance,
        registry,
        marketplace,
      } = await loadFixture(deployVotingContractFixture);
      const now = await time.latest();
      const endTime = now + 6 * 24 * 60 * 60;
      await votingContract.write.addVoting(
        ["Vote1", "Desc", ["Yes", "No"], BigInt(endTime)],
        { account: owner.account }
      );
      // Purchase user tokens
      await marketplace.write.purchaseTokens([minBalance], {
        account: user.account,
        value: tokenPrice,
      })
      return { votingContract, owner, user, other, token, minBalance, registry };
    }

    it("should revert with VotingNotActive if no votings exist", async function () {
      const { votingContract, user } = await loadFixture(deployVotingContractFixture);
      // No voting has been added yet
      await expect(
        votingContract.write.vote([0n, 0], { account: user.account })
      ).to.be.rejectedWith("VotingNotActive");
    });

    it("should allow a user with enough tokens to vote", async function () {
      const { votingContract, user } = await setupWithActiveVoting();
      await votingContract.write.vote([0n, 1], { account: user.account });
      // Should be marked as voted
      expect(await votingContract.read.voted([0n, user.account.address])).to.equal(true);
      // Vote count for variant 1 should be 1
      expect(await votingContract.read.votes([0n, 1])).to.equal(1n);
    });

    it("should revert if voting does not exist", async function () {
      const { votingContract, user } = await setupWithActiveVoting();
      await expect(
        votingContract.write.vote([1n, 0], { account: user.account })
      ).to.be.rejectedWith("VotingNotActive");
    });

    it("should revert if voting is not active", async function () {
      const { votingContract, owner, user } = await setupWithActiveVoting();
      // Fast forward past endTime
      const voting = await votingContract.read.votings([0n]) as any[];
      await time.increaseTo(Number(voting[5]) + 1);
      await expect(
        votingContract.write.vote([0n, 0], { account: user.account })
      ).to.be.rejectedWith("NoActiveVoting");
    });

    it("should revert if variant index is out of range", async function () {
      const { votingContract, user } = await setupWithActiveVoting();
      await expect(
        votingContract.write.vote([0n, 2], { account: user.account })
      ).to.be.rejectedWith("InvalidVotingVariantIndex");
    });

    it("should revert if already voted", async function () {
      const { votingContract, user } = await setupWithActiveVoting();
      await votingContract.write.vote([0n, 1], { account: user.account });
      await expect(
        votingContract.write.vote([0n, 1], { account: user.account })
      ).to.be.rejectedWith("AlreadyVoted");
    });

    it("should revert if user balance is below minimum", async function () {
      const { votingContract, other } = await setupWithActiveVoting();
      await expect(
        votingContract.write.vote([0n, 1], { account: other.account })
      ).to.be.rejectedWith("InsufficientVotingTokenBalance");
    });

    it("should revert if contract is not registered", async function () {
      const { votingContract, owner, user, registry } = await setupWithActiveVoting();
      // Unregister contract
      await registry.write.removeVotingContract([votingContract.address], { account: owner.account });
      await expect(
        votingContract.write.vote([0n, 1], { account: user.account })
      ).to.be.rejectedWith("ContractNotRegistered");
    });
  });

  describe("activeVoting & activeVotingVariants", function () {
    async function setupWithActiveVoting() {
      const { votingContract, owner } = await loadFixture(deployVotingContractFixture);
      const now = await time.latest();
      const endTime = now + 6 * 24 * 60 * 60;
      await votingContract.write.addVoting(
        ["Vote1", "Desc", ["Yes", "No"], BigInt(endTime)],
        { account: owner.account }
      );
      return { votingContract, endTime };
    }

    it("should return the active voting", async function () {
      const { votingContract } = await setupWithActiveVoting();
      const voting = await votingContract.read.activeVoting() as any;
      expect(voting.title).to.equal("Vote1");
    });

    it("should revert if no active voting", async function () {
      const { votingContract } = await loadFixture(deployVotingContractFixture);
      await expect(
        votingContract.read.activeVoting()
      ).to.be.rejectedWith("NoActiveVoting");
    });

    it("should revert if voting has ended", async function () {
      const { votingContract, endTime } = await setupWithActiveVoting();
      await time.increaseTo(Number(endTime) + 1);
      await expect(
        votingContract.read.activeVoting()
      ).to.be.rejectedWith("NoActiveVoting");
    });

    it("should return the active voting variants", async function () {
      const { votingContract } = await setupWithActiveVoting();
      const variants = await votingContract.read.activeVotingVariants() as any[];
      expect(variants.length).to.equal(2);
      expect(variants[0].title).to.equal("Yes");
      expect(variants[1].title).to.equal("No");
    });
  });

  describe("getVotingOutcome", function () {
    async function setupWithVotes() {
      const {
        votingContract,
        owner,
        user,
        other,
        token,
        minBalance,
        marketplace,
        tokenPrice,
      } = await loadFixture(deployVotingContractFixture);
      const now = await time.latest();
      const endTime = now + 6 * 24 * 60 * 60;

      await votingContract.write.addVoting(
        ["Vote1", "Desc", ["Yes", "No"], BigInt(endTime)],
        { account: owner.account }
      );

      // Purchase enough tokens for both users
      await marketplace.write.purchaseTokens([minBalance], {
        account: user.account,
        value: tokenPrice,
      })
      await marketplace.write.purchaseTokens([minBalance], {
        account: other.account,
        value: tokenPrice,
      })

      // Both vote for variant 1
      await votingContract.write.vote([0n, 1], { account: user.account });
      await votingContract.write.vote([0n, 1], { account: other.account });

      return { votingContract };
    }

    it("should return the winning variant", async function () {
      const { votingContract } = await setupWithVotes();
      const winningVariant = await votingContract.read.getVotingOutcome([0n]) as any;
      expect(winningVariant.title).to.equal("No");
    });

    it("should revert if votingId is out of range", async function () {
      const { votingContract } = await setupWithVotes();
      await expect(
        votingContract.read.getVotingOutcome([1n])
      ).to.be.rejectedWith("InvalidVotingIndex");
    });
  });
});
