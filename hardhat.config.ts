import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import 'solidity-coverage'
import "hardhat-gas-reporter";
import * as dotenv from "dotenv"
import '@tenderly/hardhat-tenderly';

dotenv.config()

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.18",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY
  },
  networks: {
    goerli: {
      url: `https://eth-goerli.alchemyapi.io/v2/${process.env.ALCHEMY_API_KEY}`,
      accounts: [`${process.env.GOERLI_PRIVATE_KEY}`]
    },
    sepolia: {
      url: `https://eth-sepolia.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY}`,
      accounts: [`${process.env.SEPOLIA_PRIVATE_KEY}`]
    },
    mainnet: {
      url: `https://eth-mainnet.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY}`,
      accounts: [`${process.env.MAINNET_PRIVATE_KEY}`]
    }
  },
  gasReporter: {
    enabled: true,
    currency: 'USD',
    gasPrice: 35,
    coinmarketcap: process.env.COINMARKETCAP_API_KEY
  }
};

export default config;
