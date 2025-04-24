import { type HardhatUserConfig, vars } from "hardhat/config";

import "@nomicfoundation/hardhat-toolbox-viem";

const INFURA_API_KEY = vars.get("INFURA_API_KEY", undefined);
const SEPOLIA_PRIVATE_KEY = vars.get("SEPOLIA_PRIVATE_KEY")

const WHITECHAIN_TESTNET_PRIVATE_KEY = vars.get("WHITECHAIN_TESTNET_PRIVATE_KEY")

const ETHERSCAN_API_KEY = vars.get("ETHERSCAN_API_KEY", undefined);

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    }
  },
  networks: {
    sepolia: INFURA_API_KEY && SEPOLIA_PRIVATE_KEY ? {
      url: `https://sepolia.infura.io/v3/${INFURA_API_KEY}`,
      accounts: [SEPOLIA_PRIVATE_KEY],
      gasPrice: 10,
    } : undefined,
    whitechainTestnet: WHITECHAIN_TESTNET_PRIVATE_KEY ? {
      url: "https://rpc-testnet.whitechain.io",
      accounts: [WHITECHAIN_TESTNET_PRIVATE_KEY]
    } : undefined
  },
  // Required for contract verification via hardhat
  etherscan: ETHERSCAN_API_KEY ? {
    apiKey: {
      sepolia: ETHERSCAN_API_KEY,
    },
  } : {},
};

export default config;
