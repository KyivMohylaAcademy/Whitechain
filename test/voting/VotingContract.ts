import { ethers, network } from "hardhat";
import { expect } from "chai";

describe("VotingContract", function () {
    let nftContract: any;
    let votingContract: any;
    let admin: any;
    let voter1: any;
    let voter2: any;
    let startTime: number;
    let endTime: number;

    beforeEach(async () => {
        [admin, voter1, voter2] = await ethers.getSigners();

        // Deploy an NFT contract (assuming an ERC721 implementation)
        const NFTContract = await ethers.getContractFactory("NFTContract");
        nftContract = await NFTContract.deploy(await admin.getAddress());
        await nftContract.waitForDeployment();

        // Mint NFTs to voter1 and voter2
        await nftContract.mint(await voter1.getAddress());
        await nftContract.mint(await voter2.getAddress());

        // Set the start and end times for voting (1 day period)
        startTime = Math.floor(Date.now() / 1000);
        endTime = startTime + 24 * 60 * 60;

        // Deploy the VotingContract
        const VotingContract = await ethers.getContractFactory("VotingContract");
        votingContract = await VotingContract.deploy(await nftContract.getAddress(), startTime, endTime);
        await votingContract.waitForDeployment();
    });

    it("should allow a user with an NFT to vote", async () => {
        // Ensure voter1 can vote
        await votingContract.connect(voter1).vote();
        expect(await votingContract.hasVoted(voter1.address)).to.be.true;
    });

    it("should not allow a user without an NFT to vote", async () => {
        // Ensure voter2 cannot vote (they don't have an NFT)
        await expect(votingContract.connect(voter2).vote()).to.be.revertedWith("You must own at least one NFT to vote.");
    });

    it("should not allow double voting from the same address", async () => {
        // Voter1 votes
        await votingContract.connect(voter1).vote();

        // Ensure voter1 cannot vote again
        await expect(votingContract.connect(voter1).vote()).to.be.revertedWith("You have already voted.");
    });

    it("should finalize voting and determine winner", async () => {
        // Ensure admin can finalize voting after the voting period ends
        await network.provider.send("evm_increaseTime", [endTime - startTime + 1]); // Advance time
        await votingContract.connect(admin).finalizeVoting();
    });

    it("should not allow finalizeVoting before the voting period ends", async () => {
        // Ensure finalizeVoting cannot be called before the voting period ends
        await expect(votingContract.connect(admin).finalizeVoting()).to.be.revertedWith("Voting period has not ended.");
    });
});
