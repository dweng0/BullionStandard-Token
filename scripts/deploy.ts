import { ethers } from "hardhat";
import * as dotenv from 'dotenv'
dotenv.config();
// exported so it can be used for testing
export const TOKEN = 'BullionStandard';
export const WETH_ADDRESS = process.env.WETH_ADDRESS;
export const ZoXExchange = process.env.EXCHANGE;

async function main() {
  if(!WETH_ADDRESS) {
    throw new Error('WETH_ADDRESS not set in .env file');
  }
  if(!ZoXExchange) {
    throw new Error('EXCHANGE not set in .env file');
  }

  const bsToken = await ethers.getContractFactory(TOKEN);
  const bsTokenContract = await bsToken.deploy(WETH_ADDRESS, ZoXExchange);

  console.log(`BS deployed to ${bsTokenContract.address}`);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
