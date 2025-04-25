'use client';

import { useEffect, useState } from 'react';
import { ethers } from 'ethers';

interface NFTGalleryProps {
  nftContract: ethers.Contract | null;
  walletAddress: string | null;
}

interface NFTItem {
  id: number;
  tokenURI: string;
}

export default function NFTGallery({ nftContract, walletAddress }: NFTGalleryProps) {
  const [nfts, setNfts] = useState<NFTItem[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  
  useEffect(() => {
    if (nftContract && walletAddress) {
      loadUserNFTs();
    }
  }, [nftContract, walletAddress]);
  
  const loadUserNFTs = async () => {
    if (!nftContract || !walletAddress) return;
    
    setLoading(true);
    setError(null);
    
    try {
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
          console.log(`Токен #${i} не існує або був спалений`);
        }
      }
      
      setNfts(userNfts);
    } catch (err) {
      console.error("Помилка при завантаженні NFT:", err);
      setError("Помилка при завантаженні ваших NFT. Спробуйте знову.");
    } finally {
      setLoading(false);
    }
  };
  
  if (loading && nfts.length === 0) {
    return (
      <div className="border rounded-lg p-6 text-center">
        <div className="flex justify-center">
          <div className="animate-spin rounded-full h-8 w-8 border-t-2 border-b-2 border-blue-500"></div>
        </div>
        <p className="mt-4 text-gray-600">Завантаження ваших NFT...</p>
      </div>
    );
  }
  
  if (error) {
    return (
      <div className="border rounded-lg p-4 bg-red-50 text-red-700">
        <p>{error}</p>
        <button 
          onClick={loadUserNFTs} 
          className="mt-2 px-3 py-1 bg-red-600 text-white rounded hover:bg-red-700"
        >
          Спробувати знову
        </button>
      </div>
    );
  }
  
  if (nfts.length === 0) {
    return (
      <div className="border rounded-lg p-6 text-center">
        <p className="text-gray-600">
          У вас поки немає NFT винагород. Проголосуйте, щоб отримати їх!
        </p>
      </div>
    );
  }
  
  return (
    <div className="border rounded-lg overflow-hidden">
      <div className="bg-purple-500 text-white p-4">
        <h2 className="text-xl font-bold">Ваші NFT ({nfts.length})</h2>
      </div>
      
      <div className="p-4">
        <div className="grid grid-cols-2 sm:grid-cols-3 gap-4">
          {nfts.map(nft => (
            <div key={nft.id} className="border rounded-lg p-3 flex flex-col items-center">
              <div className="w-full aspect-square bg-gray-100 rounded-lg flex items-center justify-center mb-2">
                <span className="text-4xl">🏆</span>
              </div>
              <p className="font-medium">NFT #{nft.id}</p>
              <p className="text-xs text-gray-500 truncate w-full text-center">
                {nft.tokenURI}
              </p>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}