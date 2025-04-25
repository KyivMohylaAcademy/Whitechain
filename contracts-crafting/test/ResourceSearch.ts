import { loadFixture, time } from "@nomicfoundation/hardhat-toolbox-viem/network-helpers";
import { expect } from "chai";
import hre from "hardhat";
import { keccak256, toBytes } from "viem";

describe("ResourceSearch", function () {
  async function deployResourceSearchFixture() {
    const [deployer, minter, user, other] = await hre.viem.getWalletClients();

    // Deploy ResourceNFT1155 and grant MINTER_ROLE to ResourceSearch
    const resourceNFT = await hre.viem.deployContract("ResourceNFT1155");
    const MINTER_ROLE = keccak256(toBytes("MINTER_ROLE"));

    // Deploy ResourceSearch with the address of resourceNFT
    const resourceSearch = await hre.viem.deployContract("ResourceSearch", [
      resourceNFT.address,
    ]);

    // Grant MINTER_ROLE to ResourceSearch contract
    await resourceNFT.write.grantRole([MINTER_ROLE, resourceSearch.address], { account: deployer.account });

    const publicClient = await hre.viem.getPublicClient();

    return {
      resourceNFT,
      resourceSearch,
      deployer,
      minter,
      user,
      other,
      MINTER_ROLE,
      publicClient,
    };
  }

  describe("Deployment", function () {
    it("should set the correct resource contract", async function () {
      const { resourceSearch, resourceNFT } = await loadFixture(deployResourceSearchFixture);
      expect((await resourceSearch.read.resourceContract()).toLowerCase()).to.equal(resourceNFT.address.toLowerCase());
    });

    it("should set default resourcesPerSearch and resourceSearchCooldown", async function () {
      const { resourceSearch } = await loadFixture(deployResourceSearchFixture);
      expect(await resourceSearch.read.resourcesPerSearch()).to.equal(3n);
      expect(await resourceSearch.read.resourceSearchCooldown()).to.equal(60n);
    });
  });

  describe("searchResources", function () {
    it("should mint resources to user and update lastSearchedResources", async function () {
      const { resourceSearch, resourceNFT, user, publicClient } = await loadFixture(deployResourceSearchFixture);

      // Call searchResources as user
      const tx = await resourceSearch.write.searchResources({ account: user.account });
      await publicClient.waitForTransactionReceipt({ hash: tx });

      // Check that lastSearchedResources was updated
      const lastSearch = await resourceSearch.read.lastSearchedResources([user.account.address]);
      const now = await time.latest();
      expect(Number(lastSearch)).to.be.closeTo(now, 2);

      // Check that user received resources (at least one resource ID should have balance > 0)
      let found = false;
      for (let id = 0; id < 6; id++) {
        const balance = await resourceNFT.read.balanceOf([user.account.address, BigInt(id)]);
        if (balance > 0n) found = true;
      }
      expect(found).to.equal(true);
    });

    it("should revert if called before cooldown is over", async function () {
      const { resourceSearch, user } = await loadFixture(deployResourceSearchFixture);

      // First call succeeds
      await resourceSearch.write.searchResources({ account: user.account });

      // Second call reverts due to cooldown
      await expect(
        resourceSearch.write.searchResources({ account: user.account })
      ).to.be.rejectedWith("TooManyAttempts");
    });

    it("should allow to search again after cooldown", async function () {
      const { resourceSearch, user } = await loadFixture(deployResourceSearchFixture);

      // First call
      await resourceSearch.write.searchResources({ account: user.account });

      // Increase time past cooldown
      const cooldown = await resourceSearch.read.resourceSearchCooldown();
      await time.increase(Number(cooldown) + 1);

      // Second call
      await expect(
        resourceSearch.write.searchResources({ account: user.account })
      ).to.be.fulfilled;
    });
  });

  describe("Owner setters", function () {
    it("should allow owner to set resource contract", async function () {
      const { resourceSearch, deployer, other } = await loadFixture(deployResourceSearchFixture);
      // Deploy another ResourceNFT1155
      const newResourceNFT = await hre.viem.deployContract("ResourceNFT1155");
      await resourceSearch.write.setResourceContract([newResourceNFT.address], { account: deployer.account });
      expect((await resourceSearch.read.resourceContract()).toLowerCase()).to.equal(newResourceNFT.address.toLowerCase());
    });

    it("should revert if non-owner tries to set resource contract", async function () {
      const { resourceSearch, other } = await loadFixture(deployResourceSearchFixture);
      const newResourceNFT = await hre.viem.deployContract("ResourceNFT1155");
      await expect(
        resourceSearch.write.setResourceContract([newResourceNFT.address], { account: other.account })
      ).to.be.rejectedWith("OwnableUnauthorizedAccount");
    });

    it("should allow owner to set resourcesPerSearch", async function () {
      const { resourceSearch, deployer } = await loadFixture(deployResourceSearchFixture);
      await resourceSearch.write.setResourcesPerSearch([7n], { account: deployer.account });
      expect(await resourceSearch.read.resourcesPerSearch()).to.equal(7n);
    });

    it("should revert if non-owner tries to set resourcesPerSearch", async function () {
      const { resourceSearch, other } = await loadFixture(deployResourceSearchFixture);
      await expect(
        resourceSearch.write.setResourcesPerSearch([7n], { account: other.account })
      ).to.be.rejectedWith("OwnableUnauthorizedAccount");
    });

    it("should allow owner to set resourceSearchCooldown", async function () {
      const { resourceSearch, deployer } = await loadFixture(deployResourceSearchFixture);
      await resourceSearch.write.setResourceSearchCooldown([123n], { account: deployer.account });
      expect(await resourceSearch.read.resourceSearchCooldown()).to.equal(123n);
    });

    it("should revert if non-owner tries to set resourceSearchCooldown", async function () {
      const { resourceSearch, other } = await loadFixture(deployResourceSearchFixture);
      await expect(
        resourceSearch.write.setResourceSearchCooldown([123n], { account: other.account })
      ).to.be.rejectedWith("OwnableUnauthorizedAccount");
    });
  });
});
