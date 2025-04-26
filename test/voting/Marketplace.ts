import { expect } from "chai";
import { ethers } from "hardhat";
import { Signer, Contract } from "ethers";

describe("Marketplace", function () {
  let marketplace: any;
  let nftContract: any;
  let owner: Signer;
  let addr1: Signer;
  let addr2: Signer;

  beforeEach(async () => {
    [owner, addr1, addr2] = await ethers.getSigners();
    
    // Deploy the NFT contract
    const NFTContractFactory = await ethers.getContractFactory("NFTContract");
    nftContract = await NFTContractFactory.deploy(await owner.getAddress());
    await nftContract.waitForDeployment();
    
    // Deploy the Marketplace contract, passing the NFT contract address
    const MarketplaceFactory = await ethers.getContractFactory("Marketplace");
    marketplace = await MarketplaceFactory.deploy(await nftContract.getAddress());
    await marketplace.waitForDeployment();

    // Mint an NFT to addr1 for testing
    await nftContract.mint(await addr1.getAddress());
  });

  it("should allow listing an NFT for sale", async function () {
    await nftContract.connect(addr1).listToken(0, ethers.parseEther("1"));

    const listing = await nftContract.listings(0);
    expect(listing.seller).to.equal(await addr1.getAddress());
    expect(listing.price).to.equal(ethers.parseEther("1"));
  });

  it("should allow canceling a listing", async function () {
    await nftContract.connect(addr1).listToken(0, ethers.parseEther("1"));
    await nftContract.connect(addr1).cancelListing(0);

    const listing = await nftContract.listings(0);
    expect(listing.price).to.equal(0);
  });

  it("should not allow purchasing an NFT that is not listed", async function () {
    await expect(
      marketplace.connect(addr2).buyNFT(0, { value: ethers.parseEther("1") })
    ).to.be.revertedWith("Token not for sale");
  });

  it("should not allow purchasing with the incorrect price", async function () {
    await nftContract.connect(addr1).listToken(0, ethers.parseEther("1"));
    await expect(
      marketplace.connect(addr2).buyNFT(0, { value: ethers.parseEther("0.5") })
    ).to.be.revertedWith("Incorrect value");
  });

  it("should check if a token is listed in the marketplace", async function () {
    await nftContract.connect(addr1).listToken(0, ethers.parseEther("1"));
    expect(await marketplace.isListed(0)).to.equal(true);
    await nftContract.connect(addr1).cancelListing(0);
    expect(await marketplace.isListed(0)).to.equal(false);
  });

  it("should get the price of a listed NFT", async function () {
    await nftContract.connect(addr1).listToken(0, ethers.parseEther("1"));
    const price = await marketplace.getListingPrice(0);
    expect(price).to.equal(ethers.parseEther("1"));
  });

  it("should not allow non-owners to list an NFT for sale via the marketplace", async function () {
    await expect(
      marketplace.connect(addr2).listNFT(0, ethers.parseEther("1"))
    ).to.be.revertedWith("Not the owner");
  });

  it("should not allow non-sellers to cancel a listing via the marketplace", async function () {
    await nftContract.connect(addr1).listToken(0, ethers.parseEther("1"));
    await expect(
      marketplace.connect(addr2).cancelListing(0)
    ).to.be.revertedWith("Not the seller");
  });
});
