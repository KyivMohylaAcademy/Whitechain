import { loadFixture } from "@nomicfoundation/hardhat-toolbox-viem/network-helpers";
import { expect } from "chai";
import hre from "hardhat";
import { bytesToHex, keccak256, toBytes } from "viem";

describe("MagicToken", function () {
  async function deployMagicTokenFixture() {
    const [deployer, minter, user] = await hre.viem.getWalletClients();
    const contract = await hre.viem.deployContract("MagicToken");
    const publicClient = await hre.viem.getPublicClient();

    const MINTER_ROLE = keccak256(toBytes("MINTER_ROLE"));
    const DEFAULT_ADMIN_ROLE = bytesToHex(toBytes(0, { size: 32 }));

    return {
      contract,
      deployer,
      minter,
      user,
      MINTER_ROLE,
      DEFAULT_ADMIN_ROLE,
      publicClient,
    };
  }

  describe("Deployment", function () {
    it("should set the correct name and symbol", async function () {
      const { contract } = await loadFixture(deployMagicTokenFixture);
      expect(await contract.read.name()).to.equal("Cossacks Business Magic Token");
      expect(await contract.read.symbol()).to.equal("CBMT");
    });

    it("should grant DEFAULT_ADMIN_ROLE to deployer", async function () {
      const { contract, deployer, DEFAULT_ADMIN_ROLE } = await loadFixture(deployMagicTokenFixture);
      expect(
        await contract.read.hasRole([DEFAULT_ADMIN_ROLE, deployer.account.address])
      ).to.equal(true);
    });
  });

  describe("mint", function () {
    it("should allow MINTER_ROLE to mint tokens", async function () {
      const { contract, deployer, minter, MINTER_ROLE, user } = await loadFixture(deployMagicTokenFixture);
      // Grant MINTER_ROLE to minter
      await contract.write.grantRole([MINTER_ROLE, minter.account.address], { account: deployer.account });
      // Mint tokens to user
      await contract.write.mint([user.account.address, 1000n], { account: minter.account });
      expect(await contract.read.balanceOf([user.account.address])).to.equal(1000n);
    });

    it("should revert if not MINTER_ROLE", async function () {
      const { contract, user } = await loadFixture(deployMagicTokenFixture);
      await expect(
        contract.write.mint([user.account.address, 1000n], { account: user.account })
      ).to.be.rejectedWith("AccessControlUnauthorizedAccount");
    });
  });
});
