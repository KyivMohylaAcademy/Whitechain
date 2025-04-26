const checkResultsBtn = document.getElementById('checkResultsBtn');
const voteBtn = document.getElementById('voteBtn');
const statusText = document.getElementById('status');
const voteIdInput = document.getElementById('voteIdInput'); // Add input element for vote ID
const optionIndexInput = document.getElementById('optionIndexInput'); // Add input element for option index

// Contract Addresses
const votingContractAddress = '0x11781Bff3e10D817202fA58E4aD3e7a3fdc775E9'; // Your VotingContractNFTReward address

// ABI for your contracts
const votingAbi = [
  "function votes(uint256 voteId) public view returns (tuple(uint256 endTime))",
  "function getResults(uint256 voteId) public view returns (uint256[] memory)",
  "function getOptions(uint256 voteId) public view returns (string[] memory)",
  "function vote(uint256 voteId, uint256 optionIndex) public"
];

let provider;
let signer;
let votingContract;

loginBtn.addEventListener('click', async () => {
  if (typeof window.ethereum === 'undefined') {
    statusText.innerText = 'MetaMask is not installed. Please install it.';
    return;
  }

  try {
    provider = new ethers.providers.Web3Provider(window.ethereum);
    await provider.send("eth_requestAccounts", []);
    signer = provider.getSigner();
    userAddress = await signer.getAddress();
    statusText.innerText = `Connected as ${userAddress}`;

    // Initialize the contract
    votingContract = new ethers.Contract(votingContractAddress, votingAbi, signer);
  } catch (err) {
    console.error(err);
    statusText.innerText = "Login failed: " + err.message;
  }
});

// Check results and voting status
checkResultsBtn.addEventListener('click', async () => {
  const voteId = parseInt(voteIdInput.value); // Get the vote ID from the input field

  // Validate the vote ID (check if it's a positive integer)
  if (isNaN(voteId) || voteId <= 0) {
    statusText.innerText = 'Please enter a valid positive vote ID.';
    return;
  }

  try {
    // Fetch vote details
    const vote = await votingContract.votes(voteId);

    const endTime = Number(vote.endTime);
    const now = Math.floor(Date.now() / 1000);

    // Display vote status
    if (now < endTime) {
      // Vote is still ongoing
      statusText.innerText = `Voting for vote ID ${voteId} is still ongoing.`;
    } else {
      // Voting has ended, show results
      const results = await votingContract.getResults(voteId);
      const options = await votingContract.getOptions(voteId);

      if (results.length === 0 || options.length === 0) {
        statusText.innerText = `Voting ID ${voteId} doesn't exist yet.`;
      } else {
        let resultText = `Results for Vote ${voteId}:\n`;
        for (let i = 0; i < results.length; i++) {
          resultText += `${options[i]}: ${results[i]} votes\n`;
        }

        statusText.innerText = resultText;
      }
    }
  } catch (err) {
    console.error('Error fetching results:', err);
    statusText.innerText = `Error fetching results: ${err.message}`;
  }
});


// Vote function
voteBtn.addEventListener('click', async () => {
  const voteId = parseInt(voteIdInput.value); // Get the vote ID from the input field
  const optionIndex = parseInt(optionIndexInput.value); // Get the option index from the input field

  // Validate the inputs (check if they're positive integers)
  if (isNaN(voteId) || voteId <= 0) {
    statusText.innerText = 'Please enter a valid positive vote ID.';
    return;
  }
  if (isNaN(optionIndex) || optionIndex < 0) {
    statusText.innerText = 'Please enter a valid option index (0 or greater).';
    return;
  }

  try {
    const tx = await votingContract.vote(voteId, optionIndex);
    await tx.wait(); // Wait for the transaction to be mined
    statusText.innerText = `Successfully voted for option ${optionIndex} in vote ${voteId}.`;
  } catch (err) {
    console.error('Error voting:', err);
    // Check for "Already voted" error and show a custom message
    if (err.message.includes("execution reverted: Already voted")) {
      statusText.innerText = `You have already voted for vote ID ${voteId}. You cannot vote again.`;
    } else {
      statusText.innerText = `Voting failed: ${err.message}`;
    }
  }
});