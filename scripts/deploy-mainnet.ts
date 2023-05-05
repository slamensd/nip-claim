
import { deploy } from "./deploy";

async function main() {

    const mainnetUSDC = '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48'
    const mainnetDelegationRegistry = '0x00000000000076A84feF008CDAbe6409d2FE638B'
    await deploy(mainnetUSDC, mainnetDelegationRegistry);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
