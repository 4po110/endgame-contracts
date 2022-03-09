// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { time } from "console";
import { ethers, upgrades } from "hardhat";

const CHAIN_ID = "cchain"

const addresses = {
  JoeRouter02: {
    "cchain": "0x60aE616a2155Ee3d9A68541Ba4544862310933d4",
    "test": ""
  },
  JoePair: {
    "cchain": "0x454e67025631c065d3cfad6d71e6892f74487a15",
    "test": ""
  },
  AnysawpV5ERC20: {
    "cchain": "0x130966628846bfd36ff31a822705796e8cb8c18d",
    "test" : ""
  }
}

async function main() {
  const [owner] = await ethers.getSigners();
  console.log("Deploying contracts with the account: ", owner.address);

  console.log("Account balance: ", (await owner.getBalance()).toString());

//==============================================================================

  // console.log("=== ENDGAME deploy START")
  // const endgameFactory = await ethers.getContractFactory("EndGame");
  // const endgameContract = await endgameFactory.deploy(
  //   0,
  //   "0xc7Cb2d08026762849e571c0C49054A1670638601"
  // );
  // await endgameContract.deployed()
  // console.log("EndGameContract deployed to: ", endgameContract.address)

//==============================================================================

  // console.log("=== EGBOND deploy START")
  // const egbondFactory = await ethers.getContractFactory("EGBond");
  // const egbondContract = await egbondFactory.deploy();
  // // await egbondContract.deployed()
  // console.log("EGBondContract deployed to: ", egbondContract.address)

//==============================================================================
  
  // console.log("=== EGSHARE deploy START")
  // const egshareFactory = await ethers.getContractFactory("EGShare");
  
  // const egshareContract = await egshareFactory.deploy(
  //   1646730747,
  //   "0xc7Cb2d08026762849e571c0C49054A1670638601",
  //   "0xc7Cb2d08026762849e571c0C49054A1670638601"
  // );
  // console.log(2)
  // // await egshareContract.deployed()
  // console.log("EGShareContract deployed to: ", egshareContract.address)

//==============================================================================

  console.log("=== Oracle deploy START")
  const oracleFactory = await ethers.getContractFactory("Oracle");
  const oracleContract = await oracleFactory.deploy(
    "0x7e9E51f0869EcB9fD5bf485535e41a7206BC4550",
    21600,
    1646805035
  );
  await oracleContract.deployed()
  console.log("Oracle deployed to: ", oracleContract.address)

//==============================================================================

  // console.log("=== Oracle deploy START")
  // const oracleFactory = await ethers.getContractFactory("Oracle");

  // const oracleContract = await oracleFactory.deploy(
  //   "0x7e9E51f0869EcB9fD5bf485535e41a7206BC4550",
  //   21600,
  //   1646805035
  // );
  // console.log(2)
  // // await egshareContract.deployed()
  // console.log("Oracle deployed to: ", oracleContract.address)

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});