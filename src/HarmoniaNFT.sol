// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract HarmoniaNFT is ERC721, Ownable {
    error NotApprovedOrOwner(address addr, uint256 tokenId);
    error InvalidTokenId(uint256 tokenId);
    error InvalidAddress();
    error NonexistentToken(uint256 tokenId);
    error OwnerAlreadySet();

    uint256 public currentTokenId = 1;
    mapping(uint256 => address) public nftOriginalOwner;
    mapping(uint256 => bool) private _tokenExists; // Mapping to track token existence

    constructor() ERC721("HarmoniaNFT", "HNFT") Ownable(msg.sender) {}

    function mint(address to) public onlyOwner {
        if (to == address(0)) {
            revert InvalidAddress();
        }
        _mint(to, currentTokenId);
        setNFTOriginalOwner(currentTokenId, to);
        _tokenExists[currentTokenId] = true; // Mark token as existing
        currentTokenId++;
    }

    function burn(uint256 tokenId) public {
        if (!_tokenExists[tokenId]) {
            revert NonexistentToken(tokenId); // Custom error for nonexistent token
        }

        if (!_isApprovedOrOwner(msg.sender, tokenId)) {
            revert NotApprovedOrOwner(msg.sender, tokenId);
        }
        _burn(tokenId); // Burn the token if approved or owner

        _tokenExists[tokenId] = false; // Mark token as non-existing after burn
    }

    function setNFTOriginalOwner(uint256 nftId, address owner) internal {
        if (nftOriginalOwner[nftId] != address(0)) {
            revert OwnerAlreadySet();
        }
        nftOriginalOwner[nftId] = owner;
    }

    function _isApprovedOrOwner(
        address spender,
        uint256 tokenId
    ) internal view returns (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner ||
            getApproved(tokenId) == spender ||
            isApprovedForAll(owner, spender));
    }

    // Function to check if a token exists
    function tokenExists(uint256 tokenId) public view returns (bool) {
        return _tokenExists[tokenId];
    }
}
