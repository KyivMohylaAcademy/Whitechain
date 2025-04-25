'use client';

import { useEffect, useState } from 'react';
import { ethers } from 'ethers';

interface MarketplacePanelProps {
  nftContract: ethers.Contract | null;
  marketplace: ethers.Contract | null;
  walletAddress: string | null;
}

interface NFTItem {
  id: number;
  tokenURI: string;
}

export default function MarketplacePanel({ 
  nftContract, 
  marketplace, 
  walletAddress 
}: MarketplacePanelProps) {
  const [nfts, setNfts] = useState<NFTItem[]>([]);
  const [coinBalance, setCoinBalance] = useState<string>("0");
  const [loading, setLoading] = useState(false);
  const [sellLoading, setSellLoading] = useState<number | null>(null);
  const [error, setError] = useState<string | null>(null);
  
  useEffect(() => {
    if (nftContract && marketplace && walletAddress) {
      loadData();
    }
  }, [nftContract, marketplace, walletAddress]);
  
  const loadData = async () => {
    if (!nftContract || !marketplace || !walletAddress) return;
    
    setLoading(true);
    setError(null);
    
    try {
      const balance = await marketplace.coinBalanceOf(walletAddress);
      setCoinBalance(ethers.formatEther(balance));
      
      const totalSupply = await nftContract.getTotalSupply();
      const userNfts: NFTItem[] = [];
      
      for (let i = 1; i <= Number(totalSupply); i++) {
        try {
          const owner = await nftContract.ownerOf(i);
          
          if (owner.toLowerCase() === walletAddress.toLowerCase()) {
            const tokenURI = await nftContract.tokenURI(i);
            userNfts.push({ id: i, tokenURI });
          }
        } catch (err) {
        }
      }
      
      setNfts(userNfts);
    } catch (err) {
      console.error("Помилка при завантаженні даних:", err);
      setError("Помилка при завантаженні даних. Спробуйте знову.");
    } finally {
      setLoading(false);
    }
  };
  
  const sellNFT = async (tokenId: number) => {
    if (!nftContract || !marketplace) return;
    
    setSellLoading(tokenId);
    
    try {
      const marketplaceAddress = await marketplace.getAddress();
      const approveTx = await nftContract.approve(marketplaceAddress, tokenId);
      await approveTx.wait();
      
      const sellTx = await marketplace.sellNFT(tokenId);
      await sellTx.wait();
      
      alert(`NFT #${tokenId} успішно продано на маркетплейсі!`);
      
      await loadData();
    } catch (err) {
      console.error("Помилка при продажу NFT:", err);
      alert("Помилка при продажу NFT. Перевірте консоль для деталей.");
    } finally {
      setSellLoading(null);
    }
  };
  
  if (loading && !coinBalance) {
    return (
      <div className="border rounded-lg p-6 text-center">
        <div className="flex justify-center">
          <div className="animate-spin rounded-full h-8 w-8 border-t-2 border-b-2 border-blue-500"></div>
        </div>
        <p className="mt-4 text-gray-600">Завантаження даних маркетплейсу...</p>
      </div>
    );
  }
  
  if (error) {
    return (
      <div className="border rounded-lg p-4 bg-red-50 text-red-700">
        <p>{error}</p>
        <button 
          onClick={loadData} 
          className="mt-2 px-3 py-1 bg-red-600 text-white rounded hover:bg-red-700"
        >
          Спробувати знову
        </button>
      </div>
    );
  }
  
  return (
    <div className="border rounded-lg overflow-hidden">
      <div className="bg-yellow-500 text-white p-4">
        <h2 className="text-xl font-bold">Маркетплейс</h2>
      </div>
      
      <div className="p-4">
        <div className="bg-yellow-50 p-4 rounded-lg mb-4">
          <p className="text-lg font-semibold">Ваш баланс коїнів: {coinBalance}</p>
        </div>
        
        <h3 className="font-semibold text-lg mb-3">Продати NFT</h3>
        
        {nfts.length === 0 ? (
          <p className="text-center text-gray-600 py-4">
            У вас немає NFT для продажу. Отримайте їх, проголосувавши!
          </p>
        ) : (
          <div className="space-y-3">
            {nfts.map(nft => (
              <div key={nft.id} className="border rounded-lg p-3 flex justify-between items-center">
                <div className="flex items-center">
                  <div className="w-10 h-10 bg-gray-100 rounded-full flex items-center justify-center mr-3">
                    <span>🏆</span>
                  </div>
                  <div>
                    <p className="font-medium">NFT #{nft.id}</p>
                    <p className="text-xs text-gray-500 truncate max-w-[150px]">
                      {nft.tokenURI}
                    </p>
                  </div>
                </div>
                <button
                  onClick={() => sellNFT(nft.id)}
                  disabled={sellLoading === nft.id}
                  className={`px-3 py-1 rounded text-white ${
                    sellLoading === nft.id ? 'bg-yellow-300 cursor-not-allowed' : 'bg-yellow-500 hover:bg-yellow-600'
                  }`}
                >
                  {sellLoading === nft.id ? 'Продаж...' : 'Продати'}
                </button>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}