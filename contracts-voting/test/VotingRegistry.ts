import {
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox-viem/network-helpers";
import { expect } from "chai";
import hre from "hardhat";
import { getAddress } from "viem";

describe("VotingRegistry", function () {
  async function deployVotingRegistryFixture() {
    const [owner, user, other, contract1, contract2] = await hre.viem.getWalletClients();
    const registry = await hre.viem.deployContract("VotingRegistry");
    const publicClient = await hre.viem.getPublicClient();

    return {
      registry,
      owner,
      user,
      other,
      contract1,
      contract2,
      publicClient,
    };
  }

  describe("Deployment", function () {
    it("Should deploy and have empty votingContracts", async function () {
      const { registry } = await loadFixture(deployVotingRegistryFixture);
      expect(registry.read.votingContracts([0n])).to.be.rejected;
    });
  });

  describe("addVotingContract", function () {
    it("registers a contract and sets sender as owner", async function () {
      const { registry, user, contract1 } = await loadFixture(deployVotingRegistryFixture);
      await registry.write.addVotingContract([contract1.account.address], { account: user.account });
      expect(await registry.read.isVotingContractRegistered([contract1.account.address])).to.equal(true);
    });

    it("reverts if contract is already registered", async function () {
      const { registry, user, contract1 } = await loadFixture(deployVotingRegistryFixture);
      await registry.write.addVotingContract([contract1.account.address], { account: user.account });
      await expect(
        registry.write.addVotingContract([contract1.account.address], { account: user.account })
      ).to.be.rejectedWith("ContractAlreadyRegistered");
    });
  });

  describe("isVotingContractRegistered", function () {
    it("returns false for unregistered contract", async function () {
      const { registry, contract1 } = await loadFixture(deployVotingRegistryFixture);
      expect(await registry.read.isVotingContractRegistered([contract1.account.address])).to.equal(false);
    });

    it("returns true for registered contract", async function () {
      const { registry, user, contract1 } = await loadFixture(deployVotingRegistryFixture);
      await registry.write.addVotingContract([contract1.account.address], { account: user.account });
      expect(await registry.read.isVotingContractRegistered([contract1.account.address])).to.equal(true);
    });
  });

  describe("removeVotingContract", function () {
    it("reverts if contract is not registered", async function () {
      const { registry, user, contract1 } = await loadFixture(deployVotingRegistryFixture);
      await expect(
        registry.write.removeVotingContract([contract1.account.address], { account: user.account })
      ).to.be.rejectedWith("ContractNotRegistered");
    });

    it("reverts if not owner or contract itself", async function () {
      const { registry, user, other, contract1 } = await loadFixture(deployVotingRegistryFixture);
      await registry.write.addVotingContract([contract1.account.address], { account: user.account });
      await expect(
        registry.write.removeVotingContract([contract1.account.address], { account: other.account })
      ).to.be.rejectedWith("Forbidden");
    });

    it("allows owner to remove contract", async function () {
      const { registry, user, contract1 } = await loadFixture(deployVotingRegistryFixture);
      await registry.write.addVotingContract([contract1.account.address], { account: user.account });
      await registry.write.removeVotingContract([contract1.account.address], { account: user.account });
      expect(await registry.read.isVotingContractRegistered([contract1.account.address])).to.equal(false);
    });

    it("allows contract itself to remove itself", async function () {
      const { registry, user, contract1 } = await loadFixture(deployVotingRegistryFixture);
      await registry.write.addVotingContract([contract1.account.address], { account: user.account });
      await registry.write.removeVotingContract([contract1.account.address], { account: contract1.account });
      expect(await registry.read.isVotingContractRegistered([contract1.account.address])).to.equal(false);
    });
  });

  describe("Voting IDs management", function () {
    async function setupWithRegisteredContract() {
      const { registry, user, contract1, other } = await loadFixture(deployVotingRegistryFixture);
      await registry.write.addVotingContract([contract1.account.address], { account: user.account });
      return { registry, user, contract1, other };
    }

    describe("addVotingContractVoting", function () {
      it("reverts if not owner or contract itself", async function () {
        const { registry, contract1, other } = await setupWithRegisteredContract();
        await expect(
          registry.write.addVotingContractVoting([contract1.account.address, 42n], { account: other.account })
        ).to.be.rejectedWith("Forbidden");
      });

      it("adds voting id by owner", async function () {
        const { registry, user, contract1 } = await setupWithRegisteredContract();
        await registry.write.addVotingContractVoting([contract1.account.address, 1n], { account: user.account });
        expect(await registry.read.getVotingContractVotings([contract1.account.address])).to.deep.equal([1n]);
      });

      it("adds voting id by contract itself", async function () {
        const { registry, contract1 } = await setupWithRegisteredContract();
        await registry.write.addVotingContractVoting([contract1.account.address, 9n], { account: contract1.account });
        expect(await registry.read.getVotingContractVotings([contract1.account.address])).to.deep.equal([9n]);
      });

      it("reverts if contract is not registered", async function () {
        const { registry, user, contract2 } = await loadFixture(deployVotingRegistryFixture);
        await expect(
          registry.write.addVotingContractVoting([contract2.account.address, 1n], { account: user.account })
        ).to.be.rejectedWith("ContractNotRegistered");
      });
    });

    describe("removeVotingContractVoting", function () {
      async function setupWithVotings() {
        const { registry, user, contract1, other } = await setupWithRegisteredContract();
        await registry.write.addVotingContractVoting([contract1.account.address, 1n], { account: user.account });
        await registry.write.addVotingContractVoting([contract1.account.address, 2n], { account: user.account });
        await registry.write.addVotingContractVoting([contract1.account.address, 3n], { account: user.account });
        return { registry, user, contract1, other };
      }

      it("removes voting id by owner", async function () {
        const { registry, user, contract1 } = await setupWithVotings();
        await registry.write.removeVotingContractVoting([contract1.account.address, 2n], { account: user.account });
        expect(await registry.read.getVotingContractVotings([contract1.account.address])).to.deep.equal([1n, 3n]);
      });

      it("removes voting id by contract itself", async function () {
        const { registry, contract1 } = await setupWithVotings();
        await registry.write.removeVotingContractVoting([contract1.account.address, 1n], { account: contract1.account });
        expect(await registry.read.getVotingContractVotings([contract1.account.address])).to.deep.equal([2n, 3n]);
      });

      it("does nothing if voting id does not exist", async function () {
        const { registry, user, contract1 } = await setupWithVotings();
        await registry.write.removeVotingContractVoting([contract1.account.address, 99n], { account: user.account });
        expect(await registry.read.getVotingContractVotings([contract1.account.address])).to.deep.equal([1n, 2n, 3n]);
      });

      it("reverts if not owner or contract itself", async function () {
        const { registry, contract1, other } = await setupWithVotings();
        await expect(
          registry.write.removeVotingContractVoting([contract1.account.address, 1n], { account: other.account })
        ).to.be.rejectedWith("Forbidden");
      });

      it("reverts if contract is not registered", async function () {
        const { registry, user, contract2 } = await loadFixture(deployVotingRegistryFixture);
        await expect(
          registry.write.removeVotingContractVoting([contract2.account.address, 1n], { account: user.account })
        ).to.be.rejectedWith("ContractNotRegistered");
      });
    });
  });

  describe("getVotingContractVotings", function () {
    it("returns empty array if none", async function () {
      const { registry, user, contract1 } = await loadFixture(deployVotingRegistryFixture);
      await registry.write.addVotingContract([contract1.account.address], { account: user.account });
      expect(await registry.read.getVotingContractVotings([contract1.account.address])).to.deep.equal([]);
    });

    it("returns all voting ids", async function () {
      const { registry, user, contract1 } = await loadFixture(deployVotingRegistryFixture);
      await registry.write.addVotingContract([contract1.account.address], { account: user.account });
      await registry.write.addVotingContractVoting([contract1.account.address, 1n], { account: user.account });
      await registry.write.addVotingContractVoting([contract1.account.address, 2n], { account: user.account });
      expect(await registry.read.getVotingContractVotings([contract1.account.address])).to.deep.equal([1n, 2n]);
    });
  });

  describe("getVotingContractVotingsCount", function () {
    it("returns 0 if none", async function () {
      const { registry, user, contract1 } = await loadFixture(deployVotingRegistryFixture);
      await registry.write.addVotingContract([contract1.account.address], { account: user.account });
      expect(await registry.read.getVotingContractVotingsCount([contract1.account.address])).to.equal(0n);
    });

    it("returns correct count", async function () {
      const { registry, user, contract1 } = await loadFixture(deployVotingRegistryFixture);
      await registry.write.addVotingContract([contract1.account.address], { account: user.account });
      await registry.write.addVotingContractVoting([contract1.account.address, 1n], { account: user.account });
      expect(await registry.read.getVotingContractVotingsCount([contract1.account.address])).to.equal(1n);
    });
  });

  describe("getVotingContractVotingByIndex", function () {
    it("returns correct voting id", async function () {
      const { registry, user, contract1 } = await loadFixture(deployVotingRegistryFixture);
      await registry.write.addVotingContract([contract1.account.address], { account: user.account });
      await registry.write.addVotingContractVoting([contract1.account.address, 10n], { account: user.account });
      await registry.write.addVotingContractVoting([contract1.account.address, 20n], { account: user.account });
      expect(await registry.read.getVotingContractVotingByIndex([contract1.account.address, 0n])).to.equal(10n);
      expect(await registry.read.getVotingContractVotingByIndex([contract1.account.address, 1n])).to.equal(20n);
    });

    it("reverts if index is out of bounds", async function () {
      const { registry, user, contract1 } = await loadFixture(deployVotingRegistryFixture);
      await registry.write.addVotingContract([contract1.account.address], { account: user.account });
      await registry.write.addVotingContractVoting([contract1.account.address, 10n], { account: user.account });
      await expect(
        registry.read.getVotingContractVotingByIndex([contract1.account.address, 1n])
      ).to.be.rejectedWith("ContractNotRegistered");
    });
  });
});
