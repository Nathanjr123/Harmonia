// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract HarmoniaNFT is ERC721, Ownable {
    error NotApprovedOrOwner(address addr, uint256 tokenId);
    error InvalidTokenId(uint256 tokenId);

    constructor() ERC721("HarmoniaNFT", "HNFT") Ownable(msg.sender) {}

    function mint(address to, uint256 tokenId) public onlyOwner {
        if (to == address(0)) {
            revert InvalidTokenId(tokenId);
        }
        _mint(to, tokenId);
    }

    function burn(uint256 tokenId) public {
        if (!_isApprovedOrOwner(msg.sender, tokenId)) {
            revert NotApprovedOrOwner(msg.sender, tokenId);
        }
        _burn(tokenId);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }
}
