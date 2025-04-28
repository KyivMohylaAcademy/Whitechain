import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
    solidity: "0.8.24",
    networks: {
        sepolia: {
            url: "https://sepolia.infura.io/v3/b821305dd3a7421d9784e2b11a509a66",
            accounts: ["0x470217e22a6cd801c54aafd5976caf2c9bee2d5c668a4192431a6362ddfb2c72"]
        }
    }
};

export default config;
