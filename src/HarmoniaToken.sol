// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract HarmoniaToken is ERC20, Ownable {
    error InvalidAddress(address addr);
    error InvalidAmount(uint256 amount);

    constructor() ERC20("Harmonia", "HRM") Ownable(msg.sender) {}

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
        if (amount == 0) {
            revert InvalidAmount(amount);
        }
        if (amount > balanceOf(msg.sender)) {
            revert InvalidAmount(amount);
        }
        
        _burn(msg.sender, amount);
    }
}
