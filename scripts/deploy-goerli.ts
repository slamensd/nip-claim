import { deploy } from "./deploy";

async function main() {
  const goerliUSDC = '0x07865c6E87B9F70255377e024ace6630C1Eaa37F';
  const goerliDelegationRegistry = '0x00000000000076A84feF008CDAbe6409d2FE638B';

  const claimer = await deploy(goerliUSDC, goerliDelegationRegistry);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
