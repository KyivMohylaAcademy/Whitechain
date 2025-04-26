import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import * as dotenv from "dotenv";
dotenv.config();

const config: HardhatUserConfig = {
  solidity: "0.8.24",
  networks: {
    whitechain: {
      url: "https://rpc-testnet.whitechain.io",
      chainId: 2625,
      accounts: [process.env.PRIVATE_KEY!],
    },
  },
};

export default config;
