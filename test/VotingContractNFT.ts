import { expect } from "chai"
import { ethers } from "hardhat"

describe("VotingContractNFT", function () {
    it("створює голосування і дозволяє голос", async function () {
        const [owner, voter] = await ethers.getSigners()

        // Деплой NFT контракту
        const NFT = await ethers.getContractFactory("MyVotingNFT")
        const nft = await NFT.deploy()
        await nft.waitForDeployment()

        // Мінтимо NFT для виборця
        await nft.mint(voter.address, "ipfs://token-uri")

        // Деплой Voting контракту і передаємо адресу NFT
        const Voting = await ethers.getContractFactory("VotingContractNFT")
        const voting = await Voting.deploy(await nft.getAddress())
        await voting.waitForDeployment()

        // Створюємо голосування
        await voting.createVoting("Що їсти на обід?", ["Суші", "Піцца", "Бургер"], 3600)

        // Виборець голосує за опцію 1 ("Піцца")
        await voting.connect(voter).vote(0, 1)

        // Перевіряємо, що результат визначено
        const result = await voting.getWinner(0)
        expect(result[0]).to.be.a("string")
        expect(Number(result[1])).to.be.greaterThanOrEqual(0)
    })

    it("не дозволяє голос без NFT", async function () {
        const [owner, stranger] = await ethers.getSigners()

        const NFT = await ethers.getContractFactory("MyVotingNFT")
        const nft = await NFT.deploy()
        await nft.waitForDeployment()

        const Voting = await ethers.getContractFactory("VotingContractNFT")
        const voting = await Voting.deploy(await nft.getAddress())
        await voting.waitForDeployment()

        await voting.createVoting("Що їсти?", ["Кебаб", "Салат"], 3600)

        await expect(
            voting.connect(stranger).vote(0, 0)
        ).to.be.revertedWith("Must own at least one NFT")
    })

    it("повертає правильну кількість голосувань", async function () {
        const [owner] = await ethers.getSigners()

        const NFT = await ethers.getContractFactory("MyVotingNFT")
        const nft = await NFT.deploy()
        await nft.waitForDeployment()
        await nft.mint(owner.address, "ipfs://token")

        const Voting = await ethers.getContractFactory("VotingContractNFT")
        const voting = await Voting.deploy(await nft.getAddress())
        await voting.waitForDeployment()

        await voting.createVoting("A", ["X"], 3600)
        await voting.createVoting("B", ["Y"], 3600)

        const count = await voting.votingCount()
        expect(Number(count)).to.equal(2)
    })

    it("перевіряє, що адреса вже голосувала", async function () {
        const [owner] = await ethers.getSigners()

        const NFT = await ethers.getContractFactory("MyVotingNFT")
        const nft = await NFT.deploy()
        await nft.waitForDeployment()
        await nft.mint(owner.address, "ipfs://token")

        const Voting = await ethers.getContractFactory("VotingContractNFT")
        const voting = await Voting.deploy(await nft.getAddress())
        await voting.waitForDeployment()

        await voting.createVoting("Тест", ["Так", "Ні"], 3600)
        await voting.vote(0, 1)

        const hasVoted = await voting.hasAddressVoted(0, owner.address)
        expect(hasVoted).to.equal(true)
    })

    it("повертає опцію та кількість голосів", async function () {
        const [owner] = await ethers.getSigners()

        const NFT = await ethers.getContractFactory("MyVotingNFT")
        const nft = await NFT.deploy()
        await nft.waitForDeployment()
        await nft.mint(owner.address, "ipfs://token")

        const Voting = await ethers.getContractFactory("VotingContractNFT")
        const voting = await Voting.deploy(await nft.getAddress())
        await voting.waitForDeployment()

        await voting.createVoting("Фрукт?", ["Яблуко", "Груша"], 3600)
        await voting.vote(0, 1) // голосуємо за \"Груша\"

        const option = await voting.getOption(0, 1)
        expect(option[0]).to.equal("Груша")
        expect(Number(option[1])).to.equal(1)
    })

    it("повертає деталі голосування", async function () {
        const [owner] = await ethers.getSigners()

        const NFT = await ethers.getContractFactory("MyVotingNFT")
        const nft = await NFT.deploy()
        await nft.waitForDeployment()
        await nft.mint(owner.address, "ipfs://token")

        const Voting = await ethers.getContractFactory("VotingContractNFT")
        const voting = await Voting.deploy(await nft.getAddress())
        await voting.waitForDeployment()

        await voting.createVoting("Чай чи кава?", ["Чай", "Кава"], 3600)

        const details = await voting.getVotingDetails(0)
        expect(details[0]).to.equal("Чай чи кава?")
        expect(details[1]).to.equal(true)         // active
        expect(Number(details[3])).to.equal(2)    // optionsCount
    })

    it("завершує голосування власником", async function () {
        const [owner] = await ethers.getSigners()

        const NFT = await ethers.getContractFactory("MyVotingNFT")
        const nft = await NFT.deploy()
        await nft.waitForDeployment()
        await nft.mint(owner.address, "ipfs://token")

        const Voting = await ethers.getContractFactory("VotingContractNFT")
        const voting = await Voting.deploy(await nft.getAddress())
        await voting.waitForDeployment()

        await voting.createVoting("Завершення?", ["Так", "Ні"], 3600)

        await voting.endVoting(0)

        const details = await voting.getVotingDetails(0)
        expect(details[1]).to.equal(false) // active == false
    })



})
