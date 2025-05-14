import React, { useState } from 'react';
import { ethers } from 'ethers';
import './App.css';

const App: React.FC = () => {
  const [walletAddress, setWalletAddress] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  const connectWallet = async () => {
    if (!window.ethereum) {
      setError('MetaMask не встановлено. Будь ласка, встановіть MetaMask.');
      return;
    }

    try {
      const provider = new ethers.BrowserProvider(window.ethereum as ethers.Eip1193Provider);
      await provider.send('eth_requestAccounts', []);
      const signer = await provider.getSigner();
      const address = await signer.getAddress();
      setWalletAddress(address);
      setError(null);
    } catch (err) {
      setError('Не вдалося підключитися до гаманця.');
      console.error(err);
    }
  };

  const logout = () => {
    setWalletAddress(null);
    setError(null);
  };

  return (
    <div className="App">
      <h1>Web3 Авторизація</h1>
      {walletAddress ? (
        <div>
          <p>Підключено: {walletAddress}</p>
          <button onClick={logout}>Вийти</button>
        </div>
      ) : (
        <button onClick={connectWallet}>Увійти через Web3</button>
      )}
      {error && <p style={{ color: 'red' }}>{error}</p>}
    </div>
  );
};

export default App;