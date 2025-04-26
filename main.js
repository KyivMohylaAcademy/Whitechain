import { ethers } from "https://esm.sh/ethers@6.6.2";

const loginBtn = document.getElementById('loginBtn');
const statusDiv = document.getElementById('status');

loginBtn.addEventListener('click', async () => {
  if (typeof window.ethereum === 'undefined') {
    alert("MetaMask is not installed.");
    return;
  }

  try {
    const provider = new ethers.BrowserProvider(window.ethereum);
    await provider.send("eth_requestAccounts", []);
    const signer = await provider.getSigner();
    const address = await signer.getAddress();

    const message = "Login to Web3 App";
    const signature = await signer.signMessage(message);
    const recoveredAddress = ethers.verifyMessage(message, signature);

    if (recoveredAddress.toLowerCase() === address.toLowerCase()) {
      statusDiv.innerText = `Logged in as: ${address}`;
    } else {
      statusDiv.innerText = `Signature verification failed.`;
    }

  } catch (err) {
    console.error(err);
    statusDiv.innerText = "Error during login.";
  }
});
