import { ethers } from "hardhat";

export const deploy = async (erc20: string, delegationRegistry: string) => {

  const Claimer = await ethers.getContractFactory("NFTClaimer");
  const claimer = await Claimer.deploy(erc20, delegationRegistry);

  console.log(
    `NFTClaimer with deployed to ${claimer.address}`
  );

  return claimer;
};