// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

contract Counter {
    uint256 private number;

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function getNumber() public view returns (uint256) {
        return number;
    }

    function increment() public {
        number++;
    }
}
