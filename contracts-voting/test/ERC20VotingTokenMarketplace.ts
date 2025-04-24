import { loadFixture } from "@nomicfoundation/hardhat-toolbox-viem/network-helpers";
import { expect } from "chai";
import hre from "hardhat";
import { parseEther } from "viem";

describe("ERC20VotingTokenMarketplace", function () {
  async function deployMarketplaceFixture() {
    const [owner, user, other] = await hre.viem.getWalletClients();
    // Deploy token
    const token = await hre.viem.deployContract("ERC20VotingToken", [
      "VotingToken",
      "VOTE",
    ]);
    // Set marketplace price (for example: 1 ether per token)
    const tokenPrice = parseEther("1"); // 1e18
    // Deploy marketplace
    const marketplace = await hre.viem.deployContract("ERC20VotingTokenMarketplace", [
      token.address,
      tokenPrice,
    ]);
    // Set marketplace as minter/burner in token
    await token.write.setMarketplaceAddress([marketplace.address], { account: owner.account });
    const publicClient = await hre.viem.getPublicClient();

    return {
      token,
      marketplace,
      owner,
      user,
      other,
      tokenPrice,
      publicClient,
    };
  }

  describe("Deployment", function () {
    it("should set the correct token and price", async function () {
      const { marketplace, token, tokenPrice } = await loadFixture(deployMarketplaceFixture);
      expect((await marketplace.read.votingToken()).toLowerCase()).to.equal(token.address.toLowerCase());
      expect(await marketplace.read.votingTokenPrice()).to.equal(tokenPrice);
    });
  });

  describe("purchaseTokens", function () {
    it("should revert if sent value is not enough", async function () {
      const { marketplace, user } = await loadFixture(deployMarketplaceFixture);
      // price is 1 ether per token, try to buy 2 with only 1 ether
      await expect(
        marketplace.write.purchaseTokens([
          // This works because tokens have 18 decimals, just as ether -> wei
          parseEther("2")
        ], {
          account: user.account,
          value: parseEther("1"),
        })
      ).to.be.rejectedWith("InsufficientValue");
    });

    it("should mint tokens to buyer and accept correct ETH", async function () {
      const { marketplace, token, user, tokenPrice } = await loadFixture(deployMarketplaceFixture);
      // price is 1 ether per token, buy 3 tokens
      await expect(
        marketplace.write.purchaseTokens([3n], {
          account: user.account,
          value: tokenPrice * 3n,
        })
      ).to.be.fulfilled;
      expect(await token.read.balanceOf([user.account.address])).to.equal(3n);
    });

    it("should allow buying multiple times and accumulate balance", async function () {
      const { marketplace, token, user, tokenPrice } = await loadFixture(deployMarketplaceFixture);
      await marketplace.write.purchaseTokens([parseEther("2")], {
        account: user.account,
        value: tokenPrice * 2n,
      });
      await marketplace.write.purchaseTokens([parseEther("1")], {
        account: user.account,
        value: tokenPrice * 1n,
      });
      expect(await token.read.balanceOf([user.account.address])).to.equal(parseEther("3"));
    });
  });

  describe("sellTokens", function () {
    async function setupWithTokensAndEther() {
      const { marketplace, token, user, owner, tokenPrice, publicClient } = await loadFixture(deployMarketplaceFixture);
      // Fund marketplace with 10 ether so it can pay sellers
      await owner.sendTransaction({ to: marketplace.address, value: parseEther("10") });
      // User buys 5 tokens
      await marketplace.write.purchaseTokens([parseEther("5")], {
        account: user.account,
        value: tokenPrice * 5n,
      });
      return { marketplace, token, user, owner, tokenPrice, publicClient };
    }

    it("should revert if user has insufficient token balance", async function () {
      const { marketplace, user } = await loadFixture(deployMarketplaceFixture);
      await expect(
        marketplace.write.sellTokens([1n], { account: user.account })
      ).to.be.rejectedWith("InsufficientTokenBalance");
    });

    it("should burn tokens and send correct ETH to user", async function () {
      const { marketplace, token, user, publicClient } = await setupWithTokensAndEther();
      const userBalanceBefore = await publicClient.getBalance({ address: user.account.address });
      // Sell 2 tokens, price is 1 ether per token, so sellValue = 2 ether
      const tx = await marketplace.write.sellTokens([parseEther("2")], { account: user.account });
      // Wait for receipt to ensure transfer
      await publicClient.waitForTransactionReceipt({ hash: tx });
      expect(await token.read.balanceOf([user.account.address])).to.equal(parseEther("3"));

      // Check that user received ETH (allowing for gas cost)
      const userBalanceAfter = await publicClient.getBalance({ address: user.account.address });
      expect(Number(userBalanceAfter - userBalanceBefore)).to.be.closeTo(Number(parseEther("2")), Number(parseEther("0.01"))); // allow for gas
    });

    it("should allow selling all tokens and reduce balance to zero", async function () {
      const { marketplace, token, user, publicClient } = await setupWithTokensAndEther();
      await marketplace.write.sellTokens([parseEther("5")], { account: user.account });
      expect(await token.read.balanceOf([user.account.address])).to.equal(0n);
    });
  });
});
