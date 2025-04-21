import { ethers } from "hardhat";

async function main() {
    const votingAddress = "0xda452E37256009f69291B6B414A9f4e234BCCcdc";
    const nftAddress = "0x2bC6F7E733152cA67C8acA82783cFd41e618e72D";

    const Voting = await ethers.getContractAt("VotingContractNFT", votingAddress);
    const NFT = await ethers.getContractAt("MyVotingNFT", nftAddress);

    const signer = (await ethers.getSigners())[0];
    const addr = await signer.getAddress();

    const votingCount = await Voting.votingCount();
    console.log("🧾 Кількість голосувань:", votingCount.toString());

    const votingId = 1; // або 0

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
