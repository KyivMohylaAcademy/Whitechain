import { ethers } from "hardhat";

async function main() {
    const votingAddress = "0x4d4095a559efbA88B1390bA47C2D247D0Eb30B73";
    const nftAddress = "0xf574b1CF543138589e2530654F7e35A96c7a55bC";

    const Voting = await ethers.getContractAt("VotingContractNFT", votingAddress);
    const NFT = await ethers.getContractAt("MyVotingNFT", nftAddress);

    const signer = (await ethers.getSigners())[0];
    const addr = await signer.getAddress();

    const votingCount = await Voting.votingCount();
    console.log("🧾 Кількість голосувань:", votingCount.toString());

    const votingId = 0; // або 0

    const [title, active, endTime, optionsCount] = await Voting.getVotingDetails(votingId);
    const balance = await NFT.balanceOf(addr);
    const hasVoted = await Voting.hasAddressVoted(votingId, addr);

    console.log("🔍 Перевірка голосування:");
    console.log("Назва:", title);
    console.log("Чи активне:", active);
    console.log("Коли закінчується:", endTime.toString());
    console.log("Кількість опцій:", optionsCount.toString());
    console.log("Є NFT:", balance.toString());
    console.log("Вже голосував:", hasVoted);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
