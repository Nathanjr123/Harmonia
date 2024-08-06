// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./HarmoniaNFT.sol";
import "forge-std/console.sol";
import {UD60x18, ud} from "@prb/math/src/UD60x18.sol";

contract HarmoniaToken is ERC20, Ownable {
    error InvalidAddress(address addr);
    error InvalidAmount(uint256 amount);

    uint256 public originalOwnerBasisPoints = 500; // 5%
    uint256 public nftOwnerBasisPoints = 9500; // 95%
    uint256 public SCALE = 10000;

    // Initial reward rate in Harmonia tokens per second
    uint256 public rewardRate;

    // Added startTime variable to track reward intervals passed
    uint256 public startTime;
    uint256 public rewardRateDecayBps = 200; // Decreases by 2% in basis points every month
    uint256 public rewardRateDecayInterval = 30 days; // Monthly decay interval

    uint256 public totalMinted;
    HarmoniaNFT public harmoniaNFT;

    mapping(uint256 => uint256) public nftListeningTime;

    constructor(
        address _HarmoniaNFTaddress
    ) ERC20("Harmonia", "HRM") Ownable(msg.sender) {
        harmoniaNFT = HarmoniaNFT(_HarmoniaNFTaddress);
        rewardRate = 0.001 ether;
        startTime = block.timestamp;
    }

    function updateListeningTime(
        uint256 nftId,
        uint256 secondsListened
    ) public onlyOwner {
        nftListeningTime[nftId] += secondsListened;
        _rewardNFT(nftId, secondsListened);
    }

    function _rewardNFT(uint256 nftId, uint256 secondsListened) public {
        // Calculate reward based on seconds listened using the _calculateReward function
        uint256 reward = _calculateReward(secondsListened);

        uint256 originalOwnerReward = (reward * originalOwnerBasisPoints) /
            SCALE;
        uint256 nftOwnerReward = (reward * nftOwnerBasisPoints) / SCALE;

        address nftOwner = harmoniaNFT.ownerOf(nftId);
        address originalOwner = harmoniaNFT.nftOriginalOwner(nftId);

        // Mint rewards to respective owners
        _mint(nftOwner, nftOwnerReward);
        _mint(originalOwner, originalOwnerReward);
    }

    function _calculateReward(
        uint256 secondsListened
    ) public returns (uint256) {
        // Calculate the reward based on seconds listened and dynamic reward rate
        uint256 _rewardRate = getCurrentRewardRate();
        uint256 reward = secondsListened * _rewardRate;

        return reward;
    }

    function getCurrentRewardRate() public returns (uint256) {
        // Get the intervals of time passed since contract was deployed.
        uint256 intervalsPassed = (block.timestamp - startTime) / 30 days;

        // If no intervals passed rewardRate remains the same
        if (intervalsPassed == 0) {
            return rewardRate;
        }

        // Calculate the decayed reward rate using percentage basis points
        rewardRateDecayBps = rewardRateDecayBps * intervalsPassed;

        // Work out the percentage to decrease the reward rate by
        uint256 percentage = (rewardRate * rewardRateDecayBps) / 10000;

        // Calculate the new reward rate
        uint256 newRate = rewardRate - percentage;

        // Update the reward rate variable to be the new rewardRate
        rewardRate = newRate;

        // Return th enew Reward Rate
        return newRate;
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
