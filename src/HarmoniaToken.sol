// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./HarmoniaNFT.sol";

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

    function updateListeningTime(uint256 nftId, uint256 secondsListened) public onlyOwner {//test this
        nftListeningTime[nftId] += secondsListened;
        _rewardNFT(nftId, secondsListened);
    }

    function _rewardNFT(uint256 nftId, uint256 secondsListened) internal {//test this 
        uint256 reward = _calculateReward(secondsListened);
        uint256 originalOwnerReward = (reward * 5) / 100;
        uint256 nftOwnerReward = reward - originalOwnerReward;

        address nftOwner = harmoniaNFT.ownerOf(nftId);
        address originalOwner = harmoniaNFT.nftOriginalOwner(nftId);

        _mint(nftOwner, nftOwnerReward);
        _mint(originalOwner, originalOwnerReward);
    }

    function _calculateReward(uint256 secondsListened) internal view returns (uint256) {//--test this
        uint256 minutesListened = ((secondsListened * 1e18) / 60) /1e18;
        if (totalMinted < BASE_REWARD) {
            return minutesListened;
        } else if (totalMinted < BASE_REWARD + SECONDARY_REWARD) {
            return minutesListened / 2;
        } else if (totalMinted < BASE_REWARD + SECONDARY_REWARD + THIRD_REWARD) {
            return minutesListened / 5;
        } else {
            return 0;
        }
    }

    function mint(address to, uint256 amount) public onlyOwner {
        if (to == address(0)) {
            revert InvalidAddress(to);
        }
        if (amount == 0) { 
            revert InvalidAmount(amount);
        }
        _mint(to, amount);
    }


    function burn(uint256 amount) public {
        if (amount == 0 || amount > balanceOf(msg.sender)) {
            revert InvalidAmount(amount);
        }
        _burn(msg.sender, amount);
    }

}
