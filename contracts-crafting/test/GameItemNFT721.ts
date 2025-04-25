import { loadFixture } from "@nomicfoundation/hardhat-toolbox-viem/network-helpers";
import { expect } from "chai";
import hre from "hardhat";
import { bytesToHex, keccak256, toBytes } from "viem";

describe("GameItemNFT721", function () {
  async function deployGameItemNFT721Fixture() {
    const [deployer, minter, burner, user] = await hre.viem.getWalletClients();
    const contract = await hre.viem.deployContract("GameItemNFT721");
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
      const { contract, deployer } = await loadFixture(deployGameItemNFT721Fixture);
      const DEFAULT_ADMIN_ROLE = bytesToHex(toBytes(0, { size: 32 }));
      expect(
        await contract.read.hasRole([DEFAULT_ADMIN_ROLE, deployer.account.address])
      ).to.equal(true);
    });

    it("should have correct name and symbol", async function () {
      const { contract } = await loadFixture(deployGameItemNFT721Fixture);
      expect(await contract.read.name()).to.equal("Cossak Business Game Item");
      expect(await contract.read.symbol()).to.equal("CGI");
    });
  });

  describe("mint", function () {
    it("should allow MINTER_ROLE to mint and assign correct URI and type", async function () {
      const { contract, deployer, minter, MINTER_ROLE, user } = await loadFixture(deployGameItemNFT721Fixture);
      // Grant MINTER_ROLE to minter
      await contract.write.grantRole([MINTER_ROLE, minter.account.address], { account: deployer.account });

      // Mint a SABER (0)
      await contract.write.mint([user.account.address, 0n], { account: minter.account });
      expect((await contract.read.ownerOf([0n])).toLowerCase()).to.equal(user.account.address.toLowerCase());
      expect(await contract.read.tokenItemTypes([0n])).to.equal(0n);
      expect(await contract.read.tokenURI([0n])).to.equal("https://cossak-business.com.ua/items/saber/0.json");
    });

    it("should mint different item types and assign correct URIs", async function () {
      const { contract, deployer, minter, MINTER_ROLE, user } = await loadFixture(deployGameItemNFT721Fixture);
      await contract.write.grantRole([MINTER_ROLE, minter.account.address], { account: deployer.account });

      // STAFF
      await contract.write.mint([user.account.address, 1n], { account: minter.account });
      expect(await contract.read.tokenURI([0n])).to.equal("https://cossak-business.com.ua/items/staff/0.json");
      // ARMOR
      await contract.write.mint([user.account.address, 2n], { account: minter.account });
      expect(await contract.read.tokenURI([1n])).to.equal("https://cossak-business.com.ua/items/armor/1.json");
      // BRACELET
      await contract.write.mint([user.account.address, 3n], { account: minter.account });
      expect(await contract.read.tokenURI([2n])).to.equal("https://cossak-business.com.ua/items/bracelet/2.json");
    });

    it("should revert if not MINTER_ROLE", async function () {
      const { contract, user } = await loadFixture(deployGameItemNFT721Fixture);
      await expect(
        contract.write.mint([user.account.address, 0n], { account: user.account })
      ).to.be.rejectedWith("AccessControlUnauthorizedAccount");
    });

    it("should revert if tokenItemType is invalid", async function () {
      const { contract, deployer, minter, MINTER_ROLE, user } = await loadFixture(deployGameItemNFT721Fixture);
      await contract.write.grantRole([MINTER_ROLE, minter.account.address], { account: deployer.account });
      await expect(
        contract.write.mint([user.account.address, 4n], { account: minter.account })
      ).to.be.rejectedWith("InvalidTokenItemType");
    });
  });

  describe("burn", function () {
    it("should allow BURNER_ROLE to burn", async function () {
      const { contract, deployer, minter, burner, MINTER_ROLE, BURNER_ROLE, user } = await loadFixture(deployGameItemNFT721Fixture);
      await contract.write.grantRole([MINTER_ROLE, minter.account.address], { account: deployer.account });
      await contract.write.grantRole([BURNER_ROLE, burner.account.address], { account: deployer.account });

      await contract.write.mint([user.account.address, 0n], { account: minter.account });
      await contract.write.burn([0n], { account: burner.account });
      await expect(contract.read.ownerOf([0n])).to.be.rejectedWith("ERC721NonexistentToken");
    });

    it("should revert if not BURNER_ROLE", async function () {
      const { contract, deployer, minter, MINTER_ROLE, user } = await loadFixture(deployGameItemNFT721Fixture);
      await contract.write.grantRole([MINTER_ROLE, minter.account.address], { account: deployer.account });
      await contract.write.mint([user.account.address, 0n], { account: minter.account });
      await expect(
        contract.write.burn([0n], { account: user.account })
      ).to.be.rejectedWith("AccessControlUnauthorizedAccount");
    });
  });

  describe("supportsInterface", function () {
    it("should support ERC721 interface", async function () {
      const { contract } = await loadFixture(deployGameItemNFT721Fixture);
      expect(
        await contract.read.supportsInterface(["0x80ac58cd"])
      ).to.equal(true);
    });

    it("should support AccessControl interface", async function () {
      const { contract } = await loadFixture(deployGameItemNFT721Fixture);
      expect(
        await contract.read.supportsInterface(["0x7965db0b"])
      ).to.equal(true);
    });

    it("should not support random interface", async function () {
      const { contract } = await loadFixture(deployGameItemNFT721Fixture);
      expect(
        await contract.read.supportsInterface(["0xffffffff"])
      ).to.equal(false);
    });
  });
});
