// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
//
contract HarmoniaToken is ERC20, Ownable {
    error InvalidAddress(address addr);
    error InvalidAmount(uint256 amount);

    uint256 public constant MAX_SUPPLY = 500_000_000 ether;
    uint256 public constant BASE_REWARD = 100_000_000 ether;
    uint256 public constant SECONDARY_REWARD = 100_000_000 ether;
    
    uint256 public totalMinted;

    mapping(uint256 => uint256) public nftListeningTime;
    mapping(uint256 => address) public nftOriginalOwner;

    constructor() ERC20("Harmonia", "HRM") Ownable(msg.sender) {}

    function setNFTOriginalOwner(uint256 nftId, address owner) public onlyOwner {
        nftOriginalOwner[nftId] = owner;
    }

    function updateListeningTime(uint256 nftId, uint256 secondsListened) public onlyOwner {
        nftListeningTime[nftId] += secondsListened;
        _rewardNFT(nftId, secondsListened);
    }

    function _rewardNFT(uint256 nftId, uint256 secondsListened) internal {
        uint256 reward = _calculateReward(secondsListened);
        uint256 originalOwnerReward = (reward * 5) / 100;
        uint256 nftOwnerReward = reward - originalOwnerReward;

        address nftOwner = ownerOfNFT(nftId);
        address originalOwner = nftOriginalOwner[nftId];

        _mint(nftOwner, nftOwnerReward);
        _mint(originalOwner, originalOwnerReward);
    }

    function _calculateReward(uint256 secondsListened) internal view returns (uint256) {
        uint256 minutesListened = secondsListened / 60;
        if (totalMinted < BASE_REWARD) {
            return minutesListened;
        } else if (totalMinted < BASE_REWARD + SECONDARY_REWARD) {
            return minutesListened / 2;
        } else {
            // Placeholder for future reward phases
            return 0;
        }
    }

    function ownerOfNFT(uint256 nftId) public view returns (address) {
        // Implement logic to return the owner of the NFT
    }

    function mint(address to, uint256 amount) public onlyOwner {
        require(totalMinted + amount <= MAX_SUPPLY, "Exceeds max supply");
        _mint(to, amount);
        totalMinted += amount;
    }

    function burn(uint256 amount) public {
        require(amount > 0, "Amount must be greater than zero");
        _burn(msg.sender, amount);
    }
}
