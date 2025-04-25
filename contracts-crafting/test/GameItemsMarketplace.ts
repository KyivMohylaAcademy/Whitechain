import { loadFixture } from "@nomicfoundation/hardhat-toolbox-viem/network-helpers";
import { expect } from "chai";
import hre from "hardhat";
import { keccak256, toBytes } from "viem";

describe("GameItemsMarketplace", function () {
  async function deployGameItemsMarketplaceFixture() {
    const [deployer, minter, user, other] = await hre.viem.getWalletClients();

    // Deploy MagicToken and grant MINTER_ROLE to marketplace
    const magicToken = await hre.viem.deployContract("MagicToken");
    const MAGIC_MINTER_ROLE = keccak256(toBytes("MINTER_ROLE"));

    // Deploy GameItemNFT721 and grant BURNER_ROLE to marketplace, MINTER_ROLE to minter
    const gameItemNFT = await hre.viem.deployContract("GameItemNFT721");
    const NFT_BURNER_ROLE = keccak256(toBytes("BURNER_ROLE"));
    const NFT_MINTER_ROLE = keccak256(toBytes("MINTER_ROLE"));

    // Deploy Marketplace
    const marketplace = await hre.viem.deployContract("GameItemsMarketplace", [
      gameItemNFT.address,
      magicToken.address,
    ]);

    // Grant MINTER_ROLE to minter for NFT minting
    await gameItemNFT.write.grantRole([NFT_MINTER_ROLE, minter.account.address], { account: deployer.account });
    // Grant BURNER_ROLE to marketplace for NFT burning
    await gameItemNFT.write.grantRole([NFT_BURNER_ROLE, marketplace.address], { account: deployer.account });
    // Grant MINTER_ROLE to marketplace for MagicToken minting
    await magicToken.write.grantRole([MAGIC_MINTER_ROLE, marketplace.address], { account: deployer.account });

    // Get item type constants and price mapping
    const SABER = Number(await gameItemNFT.read.SABER());
    const STAFF = Number(await gameItemNFT.read.STAFF());
    const ARMOR = Number(await gameItemNFT.read.ARMOR());
    const BRACELET = Number(await gameItemNFT.read.BRACELET());

    const decimals = await magicToken.read.decimals();

    const prices = {
      [SABER]: 1n * (10n ** (BigInt(decimals) - 2n)),
      [STAFF]: 2n * (10n ** (BigInt(decimals) - 2n)),
      [ARMOR]: 3n * (10n ** (BigInt(decimals) - 2n)),
      [BRACELET]: 4n * (10n ** (BigInt(decimals) - 2n)),
    };

    const publicClient = await hre.viem.getPublicClient();

    return {
      marketplace,
      gameItemNFT,
      magicToken,
      deployer,
      minter,
      user,
      other,
      SABER,
      STAFF,
      ARMOR,
      BRACELET,
      prices,
      publicClient,
      NFT_MINTER_ROLE,
    };
  }

  describe("Deployment", function () {
    it("should set correct contracts and initial prices", async function () {
      const { marketplace, gameItemNFT, magicToken, SABER, STAFF, ARMOR, BRACELET, prices } = await loadFixture(deployGameItemsMarketplaceFixture);
      expect((await marketplace.read.gameItemContract()).toLowerCase()).to.equal(gameItemNFT.address.toLowerCase());
      expect((await marketplace.read.magicTokenContract()).toLowerCase()).to.equal(magicToken.address.toLowerCase());
      expect(await marketplace.read.itemsTypesPrices([BigInt(SABER)])).to.equal(prices[SABER]);
      expect(await marketplace.read.itemsTypesPrices([BigInt(STAFF)])).to.equal(prices[STAFF]);
      expect(await marketplace.read.itemsTypesPrices([BigInt(ARMOR)])).to.equal(prices[ARMOR]);
      expect(await marketplace.read.itemsTypesPrices([BigInt(BRACELET)])).to.equal(prices[BRACELET]);
    });
  });

  describe("setItemTypesPrices", function () {
    it("should allow owner to set item type price", async function () {
      const { marketplace, deployer, SABER } = await loadFixture(deployGameItemsMarketplaceFixture);
      await marketplace.write.setItemTypesPrices([BigInt(SABER), 777n], { account: deployer.account });
      expect(await marketplace.read.itemsTypesPrices([BigInt(SABER)])).to.equal(777n);
    });

    it("should revert if non-owner tries to set price", async function () {
      const { marketplace, user, SABER } = await loadFixture(deployGameItemsMarketplaceFixture);
      await expect(
        marketplace.write.setItemTypesPrices([BigInt(SABER), 888n], { account: user.account })
      ).to.be.rejectedWith("OwnableUnauthorizedAccount");
    });
  });

  describe("sellItem", function () {
    async function mintNFTToUser(itemType: bigint) {
      const {
        gameItemNFT,
        minter,
        user,
        NFT_MINTER_ROLE,
        deployer,
      } = await loadFixture(deployGameItemsMarketplaceFixture);
      // Mint a new NFT of the given type to user
      await gameItemNFT.write.grantRole([NFT_MINTER_ROLE, minter.account.address], { account: deployer.account });
      await gameItemNFT.write.mint([user.account.address, itemType], { account: minter.account });
      // The new tokenId will be the next unused index (starts at 0 and increments)
      return 1n;
    }

    it("should revert if caller is not the owner of the item", async function () {
      const { marketplace, gameItemNFT, minter, user, other, SABER } = await loadFixture(deployGameItemsMarketplaceFixture);
      await gameItemNFT.write.mint([user.account.address, BigInt(SABER)], { account: minter.account });
      await expect(
        marketplace.write.sellItem([0n], { account: other.account })
      ).to.be.rejectedWith("NotTheOwnerOfItem");
    });

    it("should burn the NFT and mint MagicToken to the seller (SABER)", async function () {
      const { marketplace, gameItemNFT, magicToken, minter, user, SABER, prices } = await loadFixture(deployGameItemsMarketplaceFixture);
      await gameItemNFT.write.mint([user.account.address, BigInt(SABER)], { account: minter.account });

      // User sells the NFT
      await marketplace.write.sellItem([0n], { account: user.account });

      // NFT should be burned
      await expect(gameItemNFT.read.ownerOf([0n])).to.be.rejectedWith("ERC721NonexistentToken");

      // User should have received MagicTokens
      expect(await magicToken.read.balanceOf([user.account.address])).to.equal(prices[SABER]);
    });

    it("should work for all item types and mint correct MagicToken amount", async function () {
      const { marketplace, gameItemNFT, magicToken, minter, user, STAFF, ARMOR, BRACELET, prices } = await loadFixture(deployGameItemsMarketplaceFixture);

      // STAFF
      await gameItemNFT.write.mint([user.account.address, BigInt(STAFF)], { account: minter.account });
      await marketplace.write.sellItem([0n], { account: user.account });
      expect(await magicToken.read.balanceOf([user.account.address])).to.equal(prices[STAFF]);

      // ARMOR
      await gameItemNFT.write.mint([user.account.address, BigInt(ARMOR)], { account: minter.account });
      await marketplace.write.sellItem([1n], { account: user.account });
      expect(await magicToken.read.balanceOf([user.account.address])).to.equal(prices[STAFF] + prices[ARMOR]);

      // BRACELET
      await gameItemNFT.write.mint([user.account.address, BigInt(BRACELET)], { account: minter.account });
      await marketplace.write.sellItem([2n], { account: user.account });
      expect(await magicToken.read.balanceOf([user.account.address])).to.equal(prices[STAFF] + prices[ARMOR] + prices[BRACELET]);
    });
  });
});
