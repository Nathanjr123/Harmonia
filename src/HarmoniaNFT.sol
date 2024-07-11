// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract HarmoniaNFT is ERC721, Ownable {
    error NotApprovedOrOwner(address addr, uint256 tokenId);

    constructor() ERC721("HarmoniaNFT", "HNFT") Ownable(msg.sender) {}

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override {
        if (!_isApprovedOrOwner(msg.sender, tokenId)) {
            revert NotApprovedOrOwner(msg.sender, tokenId);
        }
        super._beforeTokenTransfer(from, to, tokenId);
    }
}
