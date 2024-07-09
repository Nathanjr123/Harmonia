// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract HarmoniaToken is ERC20, Ownable {
    error InvalidAddress(address addr);
    error InvalidAmount(uint256 amount);

    uint256 public constant MAX_SUPPLY = 500_000_000 ether;
    uint256 public constant BASE_REWARD = 100_000_000 ether; // Updated with 100 million tokens
    uint256 public totalMinted;

    constructor() ERC20("Harmonia", "HRM") Ownable(msg.sender) {}

    // Function to mint tokens, restricted to the owner and checks against max supply
    function mint(address to, uint256 amount) public onlyOwner {
        require(totalMinted + amount <= MAX_SUPPLY, "Exceeds max supply");
        _mint(to, amount);
        totalMinted += amount;
    }

    // Function to burn tokens, accessible to any holder
    function burn(uint256 amount) public {
        require(amount > 0, "Amount must be greater than zero");
        _burn(msg.sender, amount);
    }

    // Function to calculate reward based on minutes listened
    function calculateReward(uint256 minutesListened) public view returns (uint256) {
        // Ensure we do not exceed the base reward allocation
        uint256 remainingBaseReward = BASE_REWARD - totalMinted;
        if (minutesListened <= remainingBaseReward) {
            return minutesListened;
        } else {
            return remainingBaseReward;
        }
    }

    // Additional functions and features for Base Reward will be implemented in this branch
}
