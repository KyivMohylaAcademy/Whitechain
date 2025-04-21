import { HardhatUserConfig, task } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import * as dotenv from "dotenv";

dotenv.config();

const SEPOLIA_RPC_URL = process.env.SEPOLIA_RPC_URL || "";
const PRIVATE_KEY = process.env.PRIVATE_KEY || "";

const config: HardhatUserConfig = {
  solidity: "0.8.24",
  networks: {
    sepolia: {
      url: SEPOLIA_RPC_URL,
      accounts: PRIVATE_KEY !== "" ? [PRIVATE_KEY] : [],
    },
    // whitechain: {
    //   url: process.env.WHITECHAIN_RPC_URL || "",
    //   accounts: PRIVATE_KEY !== "" ? [PRIVATE_KEY] : [],
    // },
  },
  etherscan: {
    apiKey: {
      sepolia: "YOUR_ETHERSCAN_API_KEY", // опціонально для верифікації контрактів
    },
  },
};

task("accounts", "Prints the list of accounts", async (args, hre) => {
  const accounts = await hre.ethers.getSigners();
  for (const account of accounts) {
    console.log(account.address);
  }
});

export default config;
