import * as dotenv from "dotenv";

import { HardhatUserConfig, task } from "hardhat/config";
import "@nomiclabs/hardhat-etherscan";
import "@nomiclabs/hardhat-waffle";
import "@typechain/hardhat";
import "hardhat-gas-reporter";
import "solidity-coverage";

import "@nomiclabs/hardhat-ethers";
import "@openzeppelin/hardhat-upgrades";

dotenv.config();

const infura_api_key = process.env.INFURA_API_KEY
const privateKey = process.env.PRIVATE_KEY
const mnemonic = process.env.MNEMONIC

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();
  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

const config: HardhatUserConfig = {
  solidity: {
    compilers:[
      {
        version: "0.6.12",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          }
        }
      },
    ],
    overrides:{
      "contracts/JoeRouter02.sol": {
        version: "0.6.12",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          }
        }
      }
    }
  },
  paths:{
    cache: './build/cache',
    artifacts: './build/artifacts'
  },
  typechain:{
    outDir: './build/typechain'
  },
  networks: { 
    ava_test: {
      url: 'https://api.avax-test.network/ext/bc/C/rpc',
      accounts: privateKey !== undefined ? [privateKey] : []
    },
    avalanche: {
      url: 'https://api.avax.network/ext/bc/C/rpc',
      accounts: privateKey !== undefined ? [privateKey] : []
    },
    ftm: {
      url: 'https://speedy-nodes-nyc.moralis.io/39ecfb20d9ef4b56f690f9d0/fantom/mainnet',
      chainId: 250,
      accounts: privateKey !== undefined? [privateKey] : [],
      gasPrice: 100000000000000
    }
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
  },
  etherscan: {
    apiKey: "WU9NUJBDY3CPA1324TC19163H39CNHE3D6"    //ftm api
  },
};

export default config;
