import { loadFixture } from "@nomicfoundation/hardhat-toolbox-viem/network-helpers";
import { expect } from "chai";
import hre from "hardhat";

describe("ERC20VotingToken", function () {
  async function deployERC20VotingTokenFixture() {
    const [owner, marketplace, other] = await hre.viem.getWalletClients();
    const token = await hre.viem.deployContract("ERC20VotingToken", [
      "VotingToken",
      "VOTE",
    ]);
    const publicClient = await hre.viem.getPublicClient();

    return {
      token,
      owner,
      marketplace,
      other,
      publicClient,
    };
  }

  describe("setMarketplaceAddress", function () {
    it("should allow the owner to set marketplace address", async function () {
      const { token, owner, marketplace } = await loadFixture(deployERC20VotingTokenFixture);
      await token.write.setMarketplaceAddress([marketplace.account.address], { account: owner.account });
      expect((await token.read.marketplaceAddress()).toLowerCase()).to.equal(marketplace.account.address.toLowerCase());
    });

    it("should not allow non-owner to set marketplace address", async function () {
      const { token, other, marketplace } = await loadFixture(deployERC20VotingTokenFixture);
      await expect(
        token.write.setMarketplaceAddress([marketplace.account.address], { account: other.account })
      ).to.be.rejectedWith("OwnableUnauthorizedAccount(\"0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC\")");
    });
  });

  describe("mint", function () {
    async function fixtureWithMarketplaceSet() {
      const { token, owner, marketplace, other } = await loadFixture(deployERC20VotingTokenFixture);
      await token.write.setMarketplaceAddress([marketplace.account.address], { account: owner.account });
      return { token, owner, marketplace, other };
    }

    it("should allow marketplace to mint tokens to any address", async function () {
      const { token, marketplace, other } = await fixtureWithMarketplaceSet();
      await token.write.mint([other.account.address, 100n], { account: marketplace.account });
      expect(await token.read.balanceOf([other.account.address])).to.equal(100n);
    });

    it("should not allow non-marketplace to mint", async function () {
      const { token, other } = await fixtureWithMarketplaceSet();
      await expect(
        token.write.mint([other.account.address, 100n], { account: other.account })
      ).to.be.rejectedWith("UnauthorizedAccount");
    });

    it("should not allow minting before marketplace is set", async function () {
      const { token, owner, other } = await loadFixture(deployERC20VotingTokenFixture);
      // owner has not set marketplace yet
      await expect(
        token.write.mint([other.account.address, 100n], { account: owner.account })
      ).to.be.rejectedWith("UnauthorizedAccount");
    });
  });

  describe("burn", function () {
    async function fixtureWithMintedTokens() {
      const { token, owner, marketplace, other } = await loadFixture(deployERC20VotingTokenFixture);
      await token.write.setMarketplaceAddress([marketplace.account.address], { account: owner.account });
      await token.write.mint([other.account.address, 100n], { account: marketplace.account });
      return { token, owner, marketplace, other };
    }

    it("should allow marketplace to burn tokens from any address", async function () {
      const { token, marketplace, other } = await fixtureWithMintedTokens();
      await token.write.burn([other.account.address, 60n], { account: marketplace.account });
      expect(await token.read.balanceOf([other.account.address])).to.equal(40n);
    });

    it("should not allow non-marketplace to burn", async function () {
      const { token, other } = await fixtureWithMintedTokens();
      await expect(
        token.write.burn([other.account.address, 10n], { account: other.account })
      ).to.be.rejectedWith("UnauthorizedAccount");
    });

    it("should not allow burning before marketplace is set", async function () {
      const { token, owner, other } = await loadFixture(deployERC20VotingTokenFixture);
      await expect(
        token.write.burn([other.account.address, 10n], { account: owner.account })
      ).to.be.rejectedWith("UnauthorizedAccount");
    });
  });
});
