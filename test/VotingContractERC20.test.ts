import { ethers } from "hardhat";
import { expect } from "chai";

describe("VotingContractERC20", function () {
    it("Should allow voting if balance >= minTokens", async function () {
        const [owner, voter1] = await ethers.getSigners();

        const TokenFactory = await ethers.getContractFactory("ERC20VotingToken");
        const token = await TokenFactory.deploy();
        await token.waitForDeployment();

        const VotingFactory = await ethers.getContractFactory("VotingContractERC20");
        const voting = await VotingFactory.deploy(await token.getAddress(), 100, 3600);
        await voting.waitForDeployment();

        await token.mint(voter1.address, 200);

        await voting.addProposal("Test Proposal");

        await voting.connect(voter1).vote(0);

        const proposals = await voting.getProposals();
        expect(proposals[0].votes).to.equal(1);
    });

    it("Should not allow voting if balance < minTokens", async function () {
        const [owner, voter1] = await ethers.getSigners();

        const TokenFactory = await ethers.getContractFactory("ERC20VotingToken");
        const token = await TokenFactory.deploy();
        await token.waitForDeployment();

        const VotingFactory = await ethers.getContractFactory("VotingContractERC20");
        const voting = await VotingFactory.deploy(await token.getAddress(), 100, 3600);
        await voting.waitForDeployment();

        await token.mint(voter1.address, 50);

        await voting.addProposal("Test Proposal");

        await expect(voting.connect(voter1).vote(0)).to.be.revertedWith("Insufficient token balance");
    });

    it("Should prevent double voting", async function () {
        const [owner, voter1] = await ethers.getSigners();

        const TokenFactory = await ethers.getContractFactory("ERC20VotingToken");
        const token = await TokenFactory.deploy();
        await token.waitForDeployment();

        const VotingFactory = await ethers.getContractFactory("VotingContractERC20");
        const voting = await VotingFactory.deploy(await token.getAddress(), 100, 3600);
        await voting.waitForDeployment();

        await token.mint(voter1.address, 200);

        await voting.addProposal("Test Proposal");

        await voting.connect(voter1).vote(0);

        await expect(voting.connect(voter1).vote(0)).to.be.revertedWith("Already voted");
    });

    it("Should find winning proposal", async function () {
        const [owner, voter1, voter2] = await ethers.getSigners();

        const TokenFactory = await ethers.getContractFactory("ERC20VotingToken");
        const token = await TokenFactory.deploy();
        await token.waitForDeployment();

        const VotingFactory = await ethers.getContractFactory("VotingContractERC20");
        const voting = await VotingFactory.deploy(await token.getAddress(), 100, 3600);
        await voting.waitForDeployment();

        await token.mint(voter1.address, 200);
        await token.mint(voter2.address, 200);

        await voting.addProposal("Proposal A");
        await voting.addProposal("Proposal B");

        await voting.connect(voter1).vote(0);
        await voting.connect(voter2).vote(0);

        const winner = await voting.winningProposal();
        expect(winner).to.equal("Proposal A");
    });
});
