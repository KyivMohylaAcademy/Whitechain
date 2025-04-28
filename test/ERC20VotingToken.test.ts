import { ethers } from "hardhat";
import { expect } from "chai";

describe("ERC20VotingToken", function () {
    it("Should mint and burn tokens", async function () {
        const [owner, user] = await ethers.getSigners();

        const TokenFactory = await ethers.getContractFactory("ERC20VotingToken");
        const token = await TokenFactory.deploy();
        await token.waitForDeployment();

        await token.mint(user.address, 1000);
        expect(await token.balanceOf(user.address)).to.equal(1000);

        await token.burn(user.address, 500);
        expect(await token.balanceOf(user.address)).to.equal(500);
    });

    it("Should not allow non-owner to mint or burn", async function () {
        const [owner, user] = await ethers.getSigners();

        const TokenFactory = await ethers.getContractFactory("ERC20VotingToken");
        const token = await TokenFactory.deploy();
        await token.waitForDeployment();

        await expect(token.connect(user).mint(user.address, 1000)).to.be.reverted;
        await expect(token.connect(user).burn(user.address, 100)).to.be.reverted;
    });
});
