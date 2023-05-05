import { ethers } from 'hardhat';
import { ERC20Abi } from "./abi/ERC20";
import { BigNumber } from 'ethers'

async function main() {

  const signer = (await ethers.getSigners())[0]

  const amount = 10;
  const tokenIds = [153, 160, 159];

  const goerliUSDC = '0x07865c6E87B9F70255377e024ace6630C1Eaa37F';
  const claimer = await ethers.getContractAt("NFTClaimer", "0x8bA4F639d761Fdd2F99425af6019e8222b1Cd4C1");

  const usdc = new ethers.Contract(goerliUSDC, ERC20Abi, signer);
  
  const decimals: BigNumber = await usdc.decimals();

  const usdcAmount = decimals;

  await usdc.approve(claimer.address, usdcAmount.mul(tokenIds.length));
  await claimer.addClaims('0xdeaa72f17c397c34b784ca3d37c181048b1dd1db', tokenIds, usdcAmount);
  await claimer.claim('0xdeaa72f17c397c34b784ca3d37c181048b1dd1db', [153, 159]);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
