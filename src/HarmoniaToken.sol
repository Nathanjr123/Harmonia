// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./HarmoniaNFT.sol";
import "forge-std/console.sol";

contract HarmoniaToken is ERC20, Ownable {
    error InvalidAddress(address addr);
    error InvalidAmount(uint256 amount);

    uint256 public constant MAX_SUPPLY = 500_000_000 ether;
    uint256 public constant BASE_REWARD = 100_000_000 ether;
    uint256 public constant SECONDARY_REWARD = 100_000_000 ether;
    uint256 public constant THIRD_REWARD = 200_000_000 ether;

    uint256 public totalMinted;
    HarmoniaNFT public harmoniaNFT;

    mapping(uint256 => uint256) public nftListeningTime;

    constructor(address _HarmoniaNFTaddress) ERC20("Harmonia", "HRM") Ownable(msg.sender) {
        harmoniaNFT = HarmoniaNFT(_HarmoniaNFTaddress);
    }

    // for testing purposes (this should be removed in production)
    function setTotalMinted(uint256 _totalMinted) public {
        totalMinted = _totalMinted;
    }

    function updateListeningTime(uint256 nftId, uint256 secondsListened) public onlyOwner {
        nftListeningTime[nftId] += secondsListened;
        _rewardNFT(nftId, secondsListened);
    }

function _rewardNFT(uint256 nftId, uint256 secondsListened) public {
    // Calculate reward based on seconds listened
    uint256 rewardRate = 0.001 ether;
    uint256 reward = secondsListened * rewardRate;
    console.log("Seconds listened:", secondsListened);
    console.log("Reward:", reward);

    // Calculate rewards in basis points
    uint256 originalOwnerBasisPoints = 500; // 5%
    uint256 nftOwnerBasisPoints = 9500; // 95%

    uint256 originalOwnerReward = (reward * originalOwnerBasisPoints) / 10000;
    uint256 nftOwnerReward = (reward * nftOwnerBasisPoints) / 10000;

    console.log("Original owner reward:", originalOwnerReward);
    console.log("NFT owner reward:", nftOwnerReward);

    address nftOwner = harmoniaNFT.ownerOf(nftId);
    address originalOwner = harmoniaNFT.nftOriginalOwner(nftId);

    console.log("NFT owner address:", nftOwner);
    console.log("Original owner address:", originalOwner);

    // Mint rewards to respective owners
    _mint(nftOwner, nftOwnerReward);
    _mint(originalOwner, originalOwnerReward);
}




    function _calculateReward(uint256 secondsListened) public returns (uint256) {
    totalMinted = totalSupply();
    console.log("totalMinted: ", totalMinted);

    // Reward rate in Harmonia tokens per second
    uint256 rewardRate = 0.001 ether;

    // Calculate the reward based on seconds listened
    uint256 reward = secondsListened * rewardRate;
    console.log("Reward: ", reward);

    return reward;
}


    function mint(address to, uint256 amount) public onlyOwner {
        if (to == address(0)) {
            revert InvalidAddress(to);
        }
        if (amount == 0) {
            revert InvalidAmount(amount);
        }
        _mint(to, amount);
        totalMinted += amount;
    }

    function burn(uint256 amount) public {
        if (amount == 0 || amount > balanceOf(msg.sender)) {
            revert InvalidAmount(amount);
        }
        _burn(msg.sender, amount);
    }
}
 