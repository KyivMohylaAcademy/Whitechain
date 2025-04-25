import { loadFixture } from "@nomicfoundation/hardhat-toolbox-viem/network-helpers";
import { expect } from "chai";
import hre from "hardhat";
import { bytesToHex, bytesToString, keccak256, toBytes } from "viem";

describe("ResourceNFT1155", function () {
  async function deployResourceNFT1155Fixture() {
    const [deployer, minter, burner, user] = await hre.viem.getWalletClients();
    const contract = await hre.viem.deployContract("ResourceNFT1155");
    const publicClient = await hre.viem.getPublicClient();

    const MINTER_ROLE = keccak256(toBytes("MINTER_ROLE"));
    const BURNER_ROLE = keccak256(toBytes("BURNER_ROLE"));

    return {
      contract,
      deployer,
      minter,
      burner,
      user,
      MINTER_ROLE,
      BURNER_ROLE,
      publicClient,
    };
  }

  describe("Deployment", function () {
    it("should grant DEFAULT_ADMIN_ROLE to deployer", async function () {
      const { contract, deployer } = await loadFixture(deployResourceNFT1155Fixture);
      const DEFAULT_ADMIN_ROLE = bytesToHex(toBytes(0, { size: 32 }));
      expect(
        await contract.read.hasRole([DEFAULT_ADMIN_ROLE, deployer.account.address])
      ).to.equal(true);
    });

    it("should set the correct URI", async function () {
      const { contract } = await loadFixture(deployResourceNFT1155Fixture);
      expect(await contract.read.uri([0n])).to.equal("https://cossak-business.com.ua/resources/{id}.json");
    });
  });

  describe("mint", function () {
    it("should allow MINTER_ROLE to mint", async function () {
      const { contract, deployer, minter, MINTER_ROLE, user } = await loadFixture(deployResourceNFT1155Fixture);
      // Grant MINTER_ROLE to minter
      await contract.write.grantRole([MINTER_ROLE, minter.account.address], { account: deployer.account });
      // Mint WOOD to user
      await contract.write.mint([user.account.address, 0n, 10n], { account: minter.account });
      expect(await contract.read.balanceOf([user.account.address, 0n])).to.equal(10n);
    });

    it("should revert if not MINTER_ROLE", async function () {
      const { contract, user } = await loadFixture(deployResourceNFT1155Fixture);
      await expect(
        contract.write.mint([user.account.address, 0n, 10n], { account: user.account })
      ).to.be.rejectedWith("AccessControlUnauthorizedAccount");
    });
  });

  describe("burn", function () {
    it("should allow BURNER_ROLE to burn", async function () {
      const { contract, deployer, minter, burner, user, MINTER_ROLE, BURNER_ROLE } = await loadFixture(deployResourceNFT1155Fixture);
      // Grant MINTER_ROLE to minter and mint to user
      await contract.write.grantRole([MINTER_ROLE, minter.account.address], { account: deployer.account });
      await contract.write.mint([user.account.address, 1n, 5n], { account: minter.account });
      // Grant BURNER_ROLE to burner
      await contract.write.grantRole([BURNER_ROLE, burner.account.address], { account: deployer.account });
      // Burn IRON from user
      await contract.write.burn([user.account.address, 1n, 3n], { account: burner.account });
      expect(await contract.read.balanceOf([user.account.address, 1n])).to.equal(2n);
    });

    it("should revert if not BURNER_ROLE", async function () {
      const { contract, user } = await loadFixture(deployResourceNFT1155Fixture);
      await expect(
        contract.write.burn([user.account.address, 1n, 1n], { account: user.account })
      ).to.be.rejectedWith("AccessControlUnauthorizedAccount");
    });
  });

  describe("supportsInterface", function () {
    it("should support ERC1155 interface", async function () {
      const { contract } = await loadFixture(deployResourceNFT1155Fixture);
      expect(
        await contract.read.supportsInterface(["0xd9b67a26"])
      ).to.equal(true);
    });

    it("should support AccessControl interface", async function () {
      const { contract } = await loadFixture(deployResourceNFT1155Fixture);
      expect(
        await contract.read.supportsInterface(["0x7965db0b"])
      ).to.equal(true);
    });

    it("should not support random interface", async function () {
      const { contract } = await loadFixture(deployResourceNFT1155Fixture);
      expect(
        await contract.read.supportsInterface(["0xffffffff"])
      ).to.equal(false);
    });
  });
});
