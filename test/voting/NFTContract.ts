import { expect } from "chai";
import { ethers } from "hardhat";
import { Signer, Contract } from "ethers";

describe("NFTContract", function () {
  let nftContract: any;
  let owner: Signer;
  let addr1: Signer;
  let addr2: Signer;

  beforeEach(async () => {
    [owner, addr1, addr2] = await ethers.getSigners();
    const NFTContractFactory = await ethers.getContractFactory("NFTContract");
    nftContract = await NFTContractFactory.deploy(await owner.getAddress());
    await nftContract.waitForDeployment();
  });

  it("should mint NFTs correctly", async function () {
    await nftContract.mint(await addr1.getAddress());
    expect(await nftContract.balanceOf(await addr1.getAddress())).to.equal(1);
  });

  it("should burn NFTs correctly", async function () {
    await nftContract.mint(await addr1.getAddress());
    await nftContract.burn(await addr1.getAddress());
    expect(await nftContract.balanceOf(await addr1.getAddress())).to.equal(0);
  });

  it("should not allow burning more NFTs than owned", async function () {
    await expect(nftContract.burn(await addr1.getAddress()))
      .to.be.revertedWith("No NFTs to burn.");
  });

  it("should not allow non-owners to mint", async function () {
    await expect(
      nftContract.connect(addr1).mint(await addr1.getAddress())
    ).to.be.revertedWithCustomError(nftContract, "OwnableUnauthorizedAccount");
  });

  it("should not allow non-owners to burn", async function () {
    await nftContract.mint(await addr1.getAddress());
    await expect(
      nftContract.connect(addr1).burn(await addr1.getAddress())
    ).to.be.revertedWithCustomError(nftContract, "OwnableUnauthorizedAccount");
  });

  it("should allow listing an NFT for sale", async function () {
    await nftContract.mint(await addr1.getAddress());
    await nftContract.connect(addr1).listToken(0, ethers.parseEther("1"));

    const listing = await nftContract.listings(0);
    expect(listing.seller).to.equal(await addr1.getAddress());
    expect(listing.price).to.equal(ethers.parseEther("1"));
  });

  it("should allow canceling a listing", async function () {
    await nftContract.mint(await addr1.getAddress());
    await nftContract.connect(addr1).listToken(0, ethers.parseEther("1"));
    await nftContract.connect(addr1).cancelListing(0);

    const listing = await nftContract.listings(0);
    expect(listing.price).to.equal(0);
  });

  it("should not allow non-owners to list NFTs", async function () {
    await nftContract.mint(await addr1.getAddress());
    await expect(
      nftContract.connect(addr2).listToken(0, ethers.parseEther("1"))
    ).to.be.revertedWith("Not the owner");
  });

  it("should not allow non-sellers to cancel listing", async function () {
    await nftContract.mint(await addr1.getAddress());
    await nftContract.connect(addr1).listToken(0, ethers.parseEther("1"));
    await expect(
      nftContract.connect(addr2).cancelListing(0)
    ).to.be.revertedWith("Not the seller");
  });

  it("should allow purchasing a listed NFT", async function () {
    await nftContract.mint(await addr1.getAddress());
    await nftContract.connect(addr1).listToken(0, ethers.parseEther("1"));

    const addr1BalanceBefore = await ethers.provider.getBalance(await addr1.getAddress());

    const tx = await nftContract.connect(addr2).buyToken(0, {
      value: ethers.parseEther("1"),
    });
    const receipt = await tx.wait();
    const gasUsed = receipt?.gasUsed * receipt?.gasPrice!;

    const addr1BalanceAfter = await ethers.provider.getBalance(await addr1.getAddress());
    expect(await nftContract.ownerOf(0)).to.equal(await addr2.getAddress());
    expect(addr1BalanceAfter).to.be.closeTo(
      addr1BalanceBefore + ethers.parseEther("1"),
      ethers.parseEther("0.001") // allow minor gas tolerance
    );
  });

  it("should not allow purchasing if not listed", async function () {
    await nftContract.mint(await addr1.getAddress());
    await expect(
      nftContract.connect(addr2).buyToken(0, { value: ethers.parseEther("1") })
    ).to.be.revertedWith("Token not for sale");
  });

  it("should not allow purchasing with wrong price", async function () {
    await nftContract.mint(await addr1.getAddress());
    await nftContract.connect(addr1).listToken(0, ethers.parseEther("1"));
    await expect(
      nftContract.connect(addr2).buyToken(0, { value: ethers.parseEther("0.5") })
    ).to.be.revertedWith("Incorrect value");
  });

  it("should check if a token is listed", async function () {
    await nftContract.mint(await addr1.getAddress());
    await nftContract.connect(addr1).listToken(0, ethers.parseEther("1"));

    expect(await nftContract.isListed(0)).to.equal(true);
    await nftContract.connect(addr1).cancelListing(0);
    expect(await nftContract.isListed(0)).to.equal(false);
  });
});
