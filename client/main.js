
const marketplaceAddress = "0x336D665EF7C180B05373fa3b5D68eaa60225eE70";
const votingAddress = "0xd6e981C307D017EAAf7b6a7E90dF8ECbd53122e8";

const marketplaceABI = [
    "function buyTokens() payable",
];
const votingABI = [
    "function getProposals() public view returns (tuple(string description, uint256 votes)[])",
    "function vote(uint proposalIndex)",
];

let provider;
let signer;

async function connectWallet() {
    if (!window.ethereum) {
        alert("Install MetaMask!");
        return;
    }

    provider = new ethers.providers.Web3Provider(window.ethereum);
    await provider.send("eth_requestAccounts", []);
    signer = provider.getSigner();
    const address = await signer.getAddress();
    document.getElementById("walletAddress").innerText = `Connected: ${address}`;

    await fetchProposals();
}

window.connectWallet = connectWallet;

async function buyTokens() {
    const ethAmount = document.getElementById("ethAmount").value;
    const contract = new ethers.Contract(marketplaceAddress, marketplaceABI, signer);
    try {
        const tx = await contract.buyTokens({ value: ethers.utils.parseEther(ethAmount) });
        await tx.wait();
        alert("Tokens successfully purchased!");
    } catch (e) {
        alert("Error when purchasing: " + e.message);
    }
}

window.buyTokens = buyTokens;

async function fetchProposals() {
    const contract = new ethers.Contract(votingAddress, votingABI, provider);
    const proposals = await contract.getProposals();

    const ul = document.getElementById("proposalList");
    ul.innerHTML = "";
    proposals.forEach((proposal, index) => {
        const li = document.createElement("li");
        li.innerText = `#${index} - ${proposal.description} [${proposal.votes} votes]`;
        ul.appendChild(li);
    });
}

async function vote() {
    const index = document.getElementById("proposalIndex").value;
    const contract = new ethers.Contract(votingAddress, votingABI, signer);
    try {
        const tx = await contract.vote(index);
        await tx.wait();
        alert("Vote counted!");
        await fetchProposals();
    } catch (e) {
        alert("Failed to vote: " + e.message);
    }
}

window.vote = vote;
