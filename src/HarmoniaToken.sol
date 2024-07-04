// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract HarmoniaToken is ERC20, Ownable {
    error MintToZeroAddress();
    error MintAmountZero();
    error BurnAmountZero();
    error BurnAmountExceedsBalance();

    constructor() ERC20("Harmonia", "HRM") Ownable(msg.sender) {}

    function mint(address to, uint256 amount) public onlyOwner {
        if (to == address(0)) {
            revert MintToZeroAddress();
        }
        if (amount == 0) {
            revert MintAmountZero();
        }
        _mint(to, amount);
    }

    function burn(uint256 amount) public {
        if (amount == 0) {
            revert BurnAmountZero();
        }
        if (amount > balanceOf(msg.sender)) {
            revert BurnAmountExceedsBalance();
        }
        _burn(msg.sender, amount);
    }
}
