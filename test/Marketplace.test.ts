import { ethers } from "hardhat";
import { expect } from "chai";

describe("Marketplace", function () {
    it("Should allow buying and selling tokens", async function () {
        const [owner, buyer] = await ethers.getSigners();

        const TokenFactory = await ethers.getContractFactory("ERC20VotingToken");
        const token = await TokenFactory.deploy();
        await token.waitForDeployment();

        const MarketplaceFactory = await ethers.getContractFactory("Marketplace");
        const marketplace = await MarketplaceFactory.deploy(await token.getAddress());
        await marketplace.waitForDeployment();

        await token.transferOwnership(await marketplace.getAddress());

        // Buy tokens
        await marketplace.connect(buyer).buyTokens({ value: ethers.utils.parseEther("0.01") });

        const balance = await token.balanceOf(buyer.address);
        expect(balance).to.be.gt(0);

        // Sell tokens
        await token.connect(buyer).approve(await marketplace.getAddress(), balance);
        await marketplace.connect(buyer).sellTokens(balance);

        const balanceAfter = await token.balanceOf(buyer.address);
        expect(balanceAfter).to.equal(0);
    });

    it("Should revert buy if no ETH sent", async function () {
        const [owner, buyer] = await ethers.getSigners();

        const TokenFactory = await ethers.getContractFactory("ERC20VotingToken");
        const token = await TokenFactory.deploy();
        await token.waitForDeployment();

        const MarketplaceFactory = await ethers.getContractFactory("Marketplace");
        const marketplace = await MarketplaceFactory.deploy(await token.getAddress());
        await marketplace.waitForDeployment();

        await token.transferOwnership(await marketplace.getAddress());

        await expect(marketplace.connect(buyer).buyTokens({ value: 0 })).to.be.revertedWith("Send ETH to buy tokens");
    });

    it("Should revert sell if insufficient balance", async function () {
        const [owner, buyer] = await ethers.getSigners();

        const TokenFactory = await ethers.getContractFactory("ERC20VotingToken");
        const token = await TokenFactory.deploy();
        await token.waitForDeployment();

        const MarketplaceFactory = await ethers.getContractFactory("Marketplace");
        const marketplace = await MarketplaceFactory.deploy(await token.getAddress());
        await marketplace.waitForDeployment();

        await token.transferOwnership(await marketplace.getAddress());

        await expect(marketplace.connect(buyer).sellTokens(1000)).to.be.revertedWith("Not enough tokens");
    });
});
