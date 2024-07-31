// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./HarmoniaNFT.sol";
import "forge-std/console.sol";
import { UD60x18,ud } from "@prb/math/src/UD60x18.sol";

contract HarmoniaToken is ERC20, Ownable {
    error InvalidAddress(address addr);
    error InvalidAmount(uint256 amount);

    uint256 public originalOwnerBasisPoints = 500; // 5%
    uint256 public nftOwnerBasisPoints = 9500; // 95%
    uint256 public SCALE = 10000;

    // Initial reward rate in Harmonia tokens per second
    uint256 public initialRewardRate = 0.001 ether;
    uint256 public rewardRateDecayPercentage = 2; // Decreases by 2% every month
    uint256 public rewardRateDecayInterval = 30 days; // Monthly decay interval

    uint256 public totalMinted;
    HarmoniaNFT public harmoniaNFT;

    mapping(uint256 => uint256) public nftListeningTime;

    constructor(address _HarmoniaNFTaddress) ERC20("Harmonia", "HRM") Ownable(msg.sender) {
        harmoniaNFT = HarmoniaNFT(_HarmoniaNFTaddress);
    }

    function updateListeningTime(uint256 nftId, uint256 secondsListened) public onlyOwner {
        nftListeningTime[nftId] += secondsListened;
        _rewardNFT(nftId, secondsListened);
    }

    function _rewardNFT(uint256 nftId, uint256 secondsListened) public {
        // Calculate reward based on seconds listened using the _calculateReward function
        uint256 reward = _calculateReward(secondsListened);

        uint256 originalOwnerReward = (reward * originalOwnerBasisPoints) / SCALE;
        uint256 nftOwnerReward = (reward * nftOwnerBasisPoints) / SCALE;

        address nftOwner = harmoniaNFT.ownerOf(nftId);
        address originalOwner = harmoniaNFT.nftOriginalOwner(nftId);

        // Mint rewards to respective owners
        _mint(nftOwner, nftOwnerReward);
        _mint(originalOwner, originalOwnerReward);
    }

    function _calculateReward(uint256 secondsListened) public view returns (uint256) {
        // Calculate the reward based on seconds listened and dynamic reward rate
        uint256 rewardRate = getCurrentRewardRate();
        uint256 reward = secondsListened * rewardRate;

        return reward;
    }

    function getCurrentRewardRate() public view returns (uint256) {
        UD60x18 intervalsPassed = ud(block.timestamp).div(ud(rewardRateDecayInterval));
        UD60x18 decayFactor = ud(100 - rewardRateDecayPercentage).div(ud(100));
        UD60x18 currentRewardRate = ud(initialRewardRate).mul(decayFactor.pow(intervalsPassed));
        return currentRewardRate.unwrap();
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
