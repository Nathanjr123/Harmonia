// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract HarmoniaToken is ERC20, Ownable {
    constructor() ERC20("Harmonia", "HRM") Ownable(msg.sender) {}

   function mint(address to, uint256 amount) public onlyOwner {
        require(to != address(0), "HarmoniaToken: mint to the zero address");
        require(amount > 0, "HarmoniaToken: mint amount must be greater than zero");
        _mint(to, amount);
    }

      function burn(uint256 amount) public {
        require(amount > 0, "HarmoniaToken: burn amount must be greater than zero");
        require(amount <= balanceOf(msg.sender), "HarmoniaToken: burn amount exceeds balance");
        _burn(msg.sender, amount);
    }
}
