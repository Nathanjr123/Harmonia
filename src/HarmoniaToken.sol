// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./HarmoniaNFT.sol";
import "forge-std/console.sol";

contract HarmoniaToken is ERC20, Ownable {
    error InvalidAddress(address addr);
    error InvalidAmount(uint256 amount);

    // Calculate rewards in basis points
    uint256 public originalOwnerBasisPoints = 500; // 5%
    uint256 public nftOwnerBasisPoints = 9500; // 95%
    uint256 public SCALE = 10000;

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





    function _calculateReward(uint256 secondsListened) public pure returns (uint256) {

    // Reward rate in Harmonia tokens per second
    uint256 rewardRate = 0.001 ether;

    // Calculate the reward based on seconds listened
    uint256 reward = secondsListened * rewardRate;

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
 