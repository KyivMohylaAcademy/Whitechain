'use client';

import { useEffect, useState } from 'react';
import { ethers } from 'ethers';
import { getAllContracts, switchNetwork, getCurrentNetwork } from '@/utils/web3/contracts';
import { NETWORKS } from '@/utils/contract.addresses';
import NetworkSelector from './components/network-selector';
import VotingPanel from './components/voting-panel';
import NFTGallery from './components/nft-galery';
import MarketplacePanel from './components/marketplace-component';

declare global {
  interface Window {
    ethereum?: any;
  }
}

export default function Home() {
  const [isConnected, setIsConnected] = useState<boolean>(false);
  const [walletAddress, setWalletAddress] = useState<string | null>(null);
  const [contracts, setContracts] = useState<{
    nftContract: ethers.Contract | null;
    votingContract: ethers.Contract | null;
    marketplace: ethers.Contract | null;
    votingRegistry: ethers.Contract | null;
  }>({
    nftContract: null,
    votingContract: null,
    marketplace: null,
    votingRegistry: null
  });
  const [networkId, setNetworkId] = useState<string>('');
  const [loading, setLoading] = useState(false);

  const initContracts = async (networkIdParam?: string) => {
    if (!isConnected) return;
    
    setLoading(true);
    try {
      const result = await getAllContracts(networkIdParam);
      
      setContracts({
        nftContract: result.nftContract,
        votingContract: result.votingContract,
        marketplace: result.marketplaceContract,
        votingRegistry: result.votingRegistryContract
      });
      setNetworkId(result.networkId);
    } catch (error) {
      console.error("Помилка ініціалізації контрактів:", error);
    } finally {
      setLoading(false);
    }
  };

  const connectWallet = async () => {
    try {
      if (!window.ethereum) {
        alert("Будь ласка, встановіть MetaMask для використання цього застосунку!");
        return;
      }
      
      const accounts = await window.ethereum.request({ method: 'eth_requestAccounts' });
      
      if (accounts.length === 0) {
        return;
      }
      
      const userAddress = accounts[0];
      
      setWalletAddress(userAddress);
      setIsConnected(true);
      
      await initContracts();
      
      window.ethereum.on('accountsChanged', handleAccountsChanged);
      window.ethereum.on('chainChanged', handleChainChanged);
      
    } catch (error) {
      console.error("Помилка при підключенні гаманця:", error);
    }
  };

  const handleAccountsChanged = (accounts: string[]) => {
    if (accounts.length === 0) {
      setIsConnected(false);
      setWalletAddress(null);
    } else {
      setWalletAddress(accounts[0]);
      initContracts();
    }
  };

  const handleChainChanged = () => {
    window.location.reload();
  };

  useEffect(() => {
    if (window.ethereum && window.ethereum.isMetaMask) {
      window.ethereum.request({ method: 'eth_accounts' })
        .then(accounts => {
          if (accounts.length > 0) {
            setWalletAddress(accounts[0]);
            setIsConnected(true);
            initContracts();
          }
        })
        .catch(error => {
          console.error("Помилка при перевірці підключення:", error);
        });
    }
  }, []);

  const checkState = () => {
    alert(`Підключено: ${isConnected}
Адреса: ${walletAddress || 'Не підключено'}
Мережа: ${networkId || 'Не визначено'}
Контракт голосування: ${contracts.votingContract?.target || 'Не підключено'}`);
  };

  return (
    <main className="container mx-auto px-4 py-8">
      <div className="text-center mb-8">
        <h1 className="text-3xl font-bold mb-6">Система голосування з NFT винагородами</h1>
        
        {isConnected ? (
          <div>
            <div className="bg-green-100 px-4 py-2 rounded-lg inline-flex items-center">
              <span className="bg-green-500 rounded-full w-3 h-3 mr-2"></span>
              <span>Підключено: {walletAddress?.substring(0, 6)}...{walletAddress?.substring(walletAddress.length - 4)}</span>
            </div>
            
            <div className="mt-2">
              <span className="text-sm text-gray-600">Мережа: {NETWORKS[networkId as keyof typeof NETWORKS]?.name || networkId}</span>
              
              <div className="mt-2 space-x-2">
                <button 
                  onClick={() => switchNetwork('sepolia').then(() => initContracts('sepolia'))}
                  className={`px-3 py-1 text-sm rounded ${networkId === 'sepolia' ? 'bg-blue-500 text-white' : 'bg-gray-200'}`}
                >
                  Sepolia
                </button>
                <button 
                  onClick={() => switchNetwork('whitechain').then(() => initContracts('whitechain'))}
                  className={`px-3 py-1 text-sm rounded ${networkId === 'whitechain' ? 'bg-blue-500 text-white' : 'bg-gray-200'}`}
                >
                  Whitechain
                </button>
              </div>
            </div>
            
            <button 
              onClick={checkState}
              className="mt-2 px-3 py-1 text-sm bg-purple-100 text-purple-700 rounded hover:bg-purple-200"
            >
              Перевірити стан
            </button>
          </div>
        ) : (
          <button 
            onClick={connectWallet} 
            className="bg-blue-500 text-white px-6 py-2 rounded-lg hover:bg-blue-600"
          >
            Підключити гаманець
          </button>
        )}
      </div>
      
      {/* Main content */}
      {isConnected && loading ? (
        <div className="flex justify-center py-12">
          <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-blue-500"></div>
        </div>
      ) : isConnected ? (
        <div className="space-y-6">
          <VotingPanel 
            votingContract={contracts.votingContract} 
            walletAddress={walletAddress}
          />
          
          <NFTGallery 
            nftContract={contracts.nftContract} 
            walletAddress={walletAddress}
          />
          
          <MarketplacePanel 
            nftContract={contracts.nftContract} 
            marketplace={contracts.marketplace} 
            walletAddress={walletAddress}
          />
          
        </div>
      ) : null}
    </main>
  );
}