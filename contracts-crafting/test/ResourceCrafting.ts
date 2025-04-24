import { loadFixture } from "@nomicfoundation/hardhat-toolbox-viem/network-helpers";
import { expect } from "chai";
import hre from "hardhat";
import { keccak256, toBytes } from "viem";

describe("ResourceCrafting", function () {
  async function deployResourceCraftingFixture() {
    const [deployer, minter, burner, user, other] = await hre.viem.getWalletClients();

    // Deploy ResourceNFT1155 and grant MINTER/BURNER_ROLE to ResourceCrafting
    const resourceNFT = await hre.viem.deployContract("ResourceNFT1155");
    const MINTER_ROLE = keccak256(toBytes("MINTER_ROLE"));
    const BURNER_ROLE = keccak256(toBytes("BURNER_ROLE"));

    // Deploy GameItemNFT721 and grant MINTER_ROLE to ResourceCrafting
    const gameItemNFT = await hre.viem.deployContract("GameItemNFT721");
    const GAME_MINTER_ROLE = keccak256(toBytes("MINTER_ROLE"));

    // Deploy ResourceCrafting with both addresses
    const crafting = await hre.viem.deployContract("ResourceCrafting", [
      resourceNFT.address,
      gameItemNFT.address,
    ]);

    // Grant MINTER/BURNER_ROLE to crafting contract on ResourceNFT1155
    await resourceNFT.write.grantRole([BURNER_ROLE, crafting.address], { account: deployer.account });

    await resourceNFT.write.grantRole([MINTER_ROLE, minter.account.address], { account: deployer.account });
    await resourceNFT.write.grantRole([BURNER_ROLE, burner.account.address], { account: deployer.account });

    // Grant MINTER_ROLE to crafting contract on GameItemNFT721
    await gameItemNFT.write.grantRole([GAME_MINTER_ROLE, crafting.address], { account: deployer.account });

    // Get resource and item IDs
    const WOOD = await resourceNFT.read.WOOD();
    const IRON = await resourceNFT.read.IRON();
    const GOLD = await resourceNFT.read.GOLD();
    const LEATHER = await resourceNFT.read.LEATHER();
    const DIAMOND = await resourceNFT.read.DIAMOND();

    const SABER = await gameItemNFT.read.SABER();
    const STAFF = await gameItemNFT.read.STAFF();
    const ARMOR = await gameItemNFT.read.ARMOR();
    const BRACELET = await gameItemNFT.read.BRACELET();

    const publicClient = await hre.viem.getPublicClient();

    return {
      resourceNFT,
      gameItemNFT,
      crafting,
      deployer,
      minter,
      burner,
      user,
      other,
      WOOD,
      IRON,
      GOLD,
      LEATHER,
      DIAMOND,
      SABER,
      STAFF,
      ARMOR,
      BRACELET,
      publicClient,
    };
  }

  describe("Deployment", function () {
    it("should set correct resource and game item contract addresses", async function () {
      const { crafting, resourceNFT, gameItemNFT } = await loadFixture(deployResourceCraftingFixture);
      expect((await crafting.read.resourceContract()).toLowerCase()).to.equal(resourceNFT.address.toLowerCase());
      expect((await crafting.read.gameItemContract()).toLowerCase()).to.equal(gameItemNFT.address.toLowerCase());
    });
  });

  describe("craftItem", function () {
    it("should revert for invalid recipe index", async function () {
      const { crafting, user } = await loadFixture(deployResourceCraftingFixture);
      await expect(
        crafting.write.craftItem([999n], { account: user.account })
      ).to.be.rejectedWith("InvalidRecipeIndex");
    });

    it("should revert if user lacks any required resource", async function () {
      const { crafting, minter, burner, resourceNFT, user, SABER, IRON, WOOD, LEATHER } = await loadFixture(deployResourceCraftingFixture);

      // Only mint part of the required resources for SABER
      // SABER needs 3 IRON, 1 WOOD, 1 LEATHER
      await resourceNFT.write.mint([user.account.address, IRON, 2n], { account: minter.account.address });
      await resourceNFT.write.mint([user.account.address, WOOD, 1n], { account: minter.account.address });
      await resourceNFT.write.mint([user.account.address, LEATHER, 1n], { account: minter.account.address });

      await expect(
        crafting.write.craftItem([SABER], { account: user.account })
      ).to.be.rejectedWith("InsufficientResources");
    });

    it("should burn resources and mint item on successful craft (SABER)", async function () {
      const { crafting, minter, resourceNFT, gameItemNFT, user, SABER, IRON, WOOD, LEATHER } = await loadFixture(deployResourceCraftingFixture);

      // SABER needs 3 IRON, 1 WOOD, 1 LEATHER
      await resourceNFT.write.mint([user.account.address, IRON, 3n], { account: minter.account.address });
      await resourceNFT.write.mint([user.account.address, WOOD, 1n], { account: minter.account.address });
      await resourceNFT.write.mint([user.account.address, LEATHER, 1n], { account: minter.account.address });

      // Craft
      await crafting.write.craftItem([SABER], { account: user.account });

      // User should have item 0 (SABER)
      expect((await gameItemNFT.read.ownerOf([0n])).toLowerCase()).to.equal(user.account.address.toLowerCase());

      // Resources should be burned
      expect(await resourceNFT.read.balanceOf([user.account.address, IRON])).to.equal(0n);
      expect(await resourceNFT.read.balanceOf([user.account.address, WOOD])).to.equal(0n);
      expect(await resourceNFT.read.balanceOf([user.account.address, LEATHER])).to.equal(0n);
    });

    it("should allow crafting other recipes (STAFF, ARMOR, BRACELET)", async function () {
      const { crafting, minter, resourceNFT, gameItemNFT, user, STAFF, ARMOR, BRACELET, WOOD, GOLD, DIAMOND, LEATHER, IRON } = await loadFixture(deployResourceCraftingFixture);

      // STAFF: 2 WOOD, 1 GOLD, 1 DIAMOND
      await resourceNFT.write.mint([user.account.address, WOOD, 2n], { account: minter.account.address });
      await resourceNFT.write.mint([user.account.address, GOLD, 1n], { account: minter.account.address });
      await resourceNFT.write.mint([user.account.address, DIAMOND, 1n], { account: minter.account.address });
      await crafting.write.craftItem([STAFF], { account: user.account });
      expect((await gameItemNFT.read.ownerOf([0n])).toLowerCase()).to.equal(user.account.address.toLowerCase());

      // ARMOR: 4 LEATHER, 2 IRON, 1 GOLD
      await resourceNFT.write.mint([user.account.address, LEATHER, 4n], { account: minter.account.address });
      await resourceNFT.write.mint([user.account.address, IRON, 2n], { account: minter.account.address });
      await resourceNFT.write.mint([user.account.address, GOLD, 1n], { account: minter.account.address });
      await crafting.write.craftItem([ARMOR], { account: user.account });
      expect((await gameItemNFT.read.ownerOf([1n])).toLowerCase()).to.equal(user.account.address.toLowerCase());

      // BRACELET: 4 IRON, 2 GOLD, 2 DIAMOND
      await resourceNFT.write.mint([user.account.address, IRON, 4n], { account: minter.account.address });
      await resourceNFT.write.mint([user.account.address, GOLD, 2n], { account: minter.account.address });
      await resourceNFT.write.mint([user.account.address, DIAMOND, 2n], { account: minter.account.address });
      await crafting.write.craftItem([BRACELET], { account: user.account });
      expect((await gameItemNFT.read.ownerOf([2n])).toLowerCase()).to.equal(user.account.address.toLowerCase());
    });

    it("should burn only required amounts for each resource", async function () {
      const { crafting, minter, resourceNFT, gameItemNFT, user, SABER, IRON, WOOD, LEATHER } = await loadFixture(deployResourceCraftingFixture);

      // Mint more than required
      await resourceNFT.write.mint([user.account.address, IRON, 10n], { account: minter.account.address });
      await resourceNFT.write.mint([user.account.address, WOOD, 5n], { account: minter.account.address });
      await resourceNFT.write.mint([user.account.address, LEATHER, 5n], { account: minter.account.address });

      await crafting.write.craftItem([SABER], { account: user.account });

      // Only required amounts burned
      expect(await resourceNFT.read.balanceOf([user.account.address, IRON])).to.equal(7n);
      expect(await resourceNFT.read.balanceOf([user.account.address, WOOD])).to.equal(4n);
      expect(await resourceNFT.read.balanceOf([user.account.address, LEATHER])).to.equal(4n);
    });
  });
});
