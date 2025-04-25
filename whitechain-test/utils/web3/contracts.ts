import { ethers } from "ethers";
import NFTContractJson from "@/abi/NFTContract.json";
import MarketplaceJson from "@/abi/Marketplace.json";
import VotingContractJson from "@/abi/VotingContract.json";
import VotingRegistryJson from "@/abi/VotingRegistry.json";
import { NETWORKS, DEFAULT_NETWORK } from "@/utils/contract.addresses";

export async function getProviderAndSigner() {
  if (!window.ethereum) throw new Error("MetaMask не знайдено");
  const provider = new ethers.BrowserProvider(window.ethereum);
  const signer = await provider.getSigner();
  return { provider, signer };
}

export async function getCurrentNetwork() {
  const { provider } = await getProviderAndSigner();
  const chainId = (await provider.getNetwork()).chainId;
  
  if (Number(chainId) === 11155111) {
    return 'sepolia';
  } 
  else if (Number(chainId) === 2625) { 
    return 'whitechain';
  }
  
  return DEFAULT_NETWORK;
}

// Функція для отримання NFT контракту з урахуванням мережі
export async function getNFTContract(networkId?: string) {
  const { signer } = await getProviderAndSigner();
  const currentNetworkId = networkId || await getCurrentNetwork();
  const network = NETWORKS[currentNetworkId as keyof typeof NETWORKS];
  return new ethers.Contract(network.nftContract, NFTContractJson.abi, signer);
}

// Функція для отримання Marketplace контракту з урахуванням мережі
export async function getMarketplaceContract(networkId?: string) {
  const { signer } = await getProviderAndSigner();
  const currentNetworkId = networkId || await getCurrentNetwork();
  const network = NETWORKS[currentNetworkId as keyof typeof NETWORKS];
  return new ethers.Contract(network.marketplace, MarketplaceJson.abi, signer);
}

// Функція для отримання Voting контракту з урахуванням мережі
export async function getVotingContract(networkId?: string) {
  const { signer } = await getProviderAndSigner();
  const currentNetworkId = networkId || await getCurrentNetwork();
  const network = NETWORKS[currentNetworkId as keyof typeof NETWORKS];
  return new ethers.Contract(network.votingContract, VotingContractJson.abi, signer);
}

// Функція для отримання VotingRegistry контракту з урахуванням мережі
export async function getVotingRegistryContract(networkId?: string) {
  const { signer } = await getProviderAndSigner();
  const currentNetworkId = networkId || await getCurrentNetwork();
  const network = NETWORKS[currentNetworkId as keyof typeof NETWORKS];
  return new ethers.Contract(network.votingRegistry, VotingRegistryJson.abi, signer);
}

// Функція для отримання всіх контрактів одразу
export async function getAllContracts(networkId?: string) {
  const currentNetworkId = networkId || await getCurrentNetwork();
  
  const nftContract = await getNFTContract(currentNetworkId);
  const marketplaceContract = await getMarketplaceContract(currentNetworkId);
  const votingContract = await getVotingContract(currentNetworkId);
  const votingRegistryContract = await getVotingRegistryContract(currentNetworkId);
  
  return {
    nftContract,
    marketplaceContract,
    votingContract,
    votingRegistryContract,
    networkId: currentNetworkId
  };
}

// Функція для зміни мережі
export async function switchNetwork(networkId: string) {
  if (!window.ethereum) throw new Error("MetaMask не знайдено");
  
  try {
    if (networkId === 'sepolia') {
      await window.ethereum.request({
        method: 'wallet_switchEthereumChain',
        params: [{ chainId: '0xAA36A7' }], 
      });
    } else if (networkId === 'whitechain') {
      try {
        await window.ethereum.request({
          method: 'wallet_switchEthereumChain',
          params: [{ chainId: '0xa41' }],
        });
      } catch (error: any) {

        if (error.code === 4902) {
          await window.ethereum.request({
            method: 'wallet_addEthereumChain',
            params: [
              {
                chainId: '0xa41',
                chainName: 'Whitechain Testnet',
                nativeCurrency: {
                  name: 'WHC',
                  symbol: 'WHC',
                  decimals: 18
                },
                rpcUrls: ['https://rpc-testnet.whitechain.io'],
                blockExplorerUrls: ['https://explorer-testnet.whitechain.io/']
              },
            ],
          });
        } else {
          throw error;
        }
      }
    }
    return true;
  } catch (error) {
    console.error("Помилка при зміні мережі:", error);
    throw error;
  }
}