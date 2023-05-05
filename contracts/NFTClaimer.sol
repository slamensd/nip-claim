// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IDelegationRegistry} from "./IDelegationRegistry.sol";

contract NFTClaimer is Ownable {
    error NothingToClaim();
    error NoTokensSpecified();
    error NotValidERC721();
    error CallerNotOwnerOfToken(uint256 tokenId);
    error CallerNotDelegatedToken(uint256 tokenId);

    event ClaimsAdded(address indexed _nft, uint256 indexed _amountPerNft, uint256[] _tokenIds);
    event Claimed(address indexed _nft, uint256 indexed _totalAmount, uint256[] _tokenIds);

    IERC20 public erc20;
    IDelegationRegistry public delegationRegistry;

    // Total claimable ERC20 tokens across all claims
    uint256 public totalClaimable;

    // Mapping of NFT contract => token id => claimable ERC20
    mapping(address => mapping(uint256 => uint256)) private claims;

    constructor(IERC20 erc20_, IDelegationRegistry delegationRegistry_) {
        erc20 = erc20_;
        delegationRegistry = delegationRegistry_;
    }

    /**
     * Adds claimable ERC-20 tokens for the provided NFT contract and token ids
     * @param nft NFT Contract to add claims for
     * @param tokenIds Token IDs with claims
     * @param claimPerNft Claimable amount per token
     */
    function addClaims(address nft, uint256[] calldata tokenIds, uint256 claimPerNft) external onlyOwner {
        validateTokensProvided(tokenIds);

        uint256 count = tokenIds.length;
        uint256 totalAmount = claimPerNft * count;
        totalClaimable += totalAmount;

        for (uint256 i; i < count; ) {
            claims[nft][tokenIds[i]] += claimPerNft;

            unchecked {
                ++i;
            }
        }

        emit ClaimsAdded(nft, claimPerNft, tokenIds);

        erc20.transferFrom(msg.sender, address(this), totalAmount);
    }

    /**
     * Owner withdraw of ERC-20 tokens
     * @param amount Amount to withdraw
     */
    function withdrawERC20(uint256 amount) external onlyOwner {
        erc20.transfer(owner(), amount);
    }

    /**
     * Claims ERC-20 tokens for the provided NFTs
     * @param nft NFT contract to claim for
     * @param tokenIds Token IDs to claim for. Must be owned by caller.
     */
    function claim(address nft, uint256[] calldata tokenIds) external {
        validateTokensProvided(tokenIds);

        IERC721 erc721 = IERC721(nft);

        uint256 claimable;
        for (uint256 i; i < tokenIds.length; ) {
            uint256 tokenId = tokenIds[i];

            claimable += popClaim(nft, tokenId);

            validateOwnerOfToken(erc721, msg.sender, tokenId);

            unchecked {
                ++i;
            }
        }

        emit Claimed(nft, claimable, tokenIds);

        processClaim(msg.sender, claimable);
    }

    /**
     * Claims ERC-20 tokens as a delegated hot wallet for the provided vault
     * @param nft NFT contract to claim for
     * @param tokenIds Token IDs to claim for. Must be owned by vault.
     * @param vault Vault/cold wallet to claim tokens for
     * @param sendToVault Indicates if the ERC-20 tokens should be sent to the hot wallet or the vault wallet
     */
    function claimAsDelegate(address nft, uint256[] calldata tokenIds, address vault, bool sendToVault) external {
        validateTokensProvided(tokenIds);

        bool isDelegateForContract = delegationRegistry.checkDelegateForContract(msg.sender, vault, nft);

        IERC721 erc721 = IERC721(nft);

        uint256 claimable;
        for (uint256 i; i < tokenIds.length; ) {
            uint256 tokenId = tokenIds[i];

            claimable += popClaim(nft, tokenId);

            bool isDelegateForToken = isDelegateForContract;
            if (!isDelegateForToken) {
                isDelegateForToken = delegationRegistry.checkDelegateForToken(msg.sender, vault, nft, tokenId);
            }

            if (!isDelegateForToken) {
                revert CallerNotDelegatedToken(tokenId);
            }

            validateOwnerOfToken(erc721, vault, tokenId);
            unchecked {
                ++i;
            }
        }

        emit Claimed(nft, claimable, tokenIds);

        address withdrawAddress = sendToVault ? vault : msg.sender;
        processClaim(withdrawAddress, claimable);
    }

    /**
     * Gets claimable ERC-20 amounts for the provided NFT tokens
     * @param nft NFT contract address
     * @param tokenIds Token IDs to get claims for
     */
    function getClaimable(address nft, uint256[] calldata tokenIds) external view returns (uint256[] memory) {
        uint256 count = tokenIds.length;

        uint256[] memory claimable = new uint256[](count);
        for (uint256 i; i < count; ) {
            uint256 tokenId = tokenIds[i];
            claimable[i] = claims[nft][tokenId];
            unchecked {
                ++i;
            }
        }

        return claimable;
    }

    /**
     * Reverts if the provided list of token ids is empty
     * @param tokenIds List of token ids to check
     */
    function validateTokensProvided(uint256[] calldata tokenIds) internal pure {
        if (tokenIds.length == 0) {
            revert NoTokensSpecified();
        }
    }

    /**
     * Checks ERC721 ownership and reverts if the owner does not match the expected value
     * @param erc721 ERC721 contract to check ownership
     * @param owner_ Address to check as owner
     * @param tokenId Token ID to check ownership of
     */
    function validateOwnerOfToken(IERC721 erc721, address owner_, uint256 tokenId) internal view {
        address ownerOfToken = erc721.ownerOf(tokenId);
        if (ownerOfToken != owner_) {
            revert CallerNotOwnerOfToken(tokenId);
        }
    }

    /**
     * Processes an ERC-20 claim withdrawal or reverts if the amount is zero
     * @param to Address to withdraw to
     * @param amount Amount to be sent
     */
    function processClaim(address to, uint256 amount) private {
        if (amount == 0) {
            revert NothingToClaim();
        }

        totalClaimable -= amount;
        erc20.transfer(to, amount);
    }

    /**
     * Pops a claim from the claim mapping and returns the value being claimed
     * @param nft NFT contract to get claimable amount for
     * @param tokenId Token ID to get claimable amount for
     */
    function popClaim(address nft, uint256 tokenId) private returns (uint256) {
        uint256 claimable = claims[nft][tokenId];
        delete claims[nft][tokenId];

        return claimable;
    }
}
