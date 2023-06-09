const CONTRACT_ADDRESS = '0x9674739124d69d555712a30e0a44de648f494219';
const CONTRACT_ABI = 'YOUR_CONTRACT_ABI'; // Replace with your contract ABI

// Connect wallet button event
document.getElementById('connectWalletButton').addEventListener('click', async () => {
    try {
        const providerOptions = {}; // Add any specific provider options if needed
        const Web3Modal = window.Web3Modal.default;
        const web3Modal = new Web3Modal({ providerOptions });
        const connection = await web3Modal.connect();
        const provider = new ethers.providers.Web3Provider(connection);
        const signer = provider.getSigner();
        const contract = new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, signer);
        const account = await signer.getAddress();

        // Check if the connected wallet is the owner of the contract
        const contractOwner = await contract.owner();
        if (account.toLowerCase() === contractOwner.toLowerCase()) {
            document.getElementById('ownerSection').classList.remove('hidden');
            document.getElementById('ownerApp').innerHTML = await (await fetch('owner.html')).text();
        } else {
            document.getElementById('userSection').classList.remove('hidden');
            document.getElementById('userApp').innerHTML = await (await fetch('user.html')).text();
        }
    } catch (error) {
        console.error(error);
        alert('Error connecting wallet.');
    }
});
