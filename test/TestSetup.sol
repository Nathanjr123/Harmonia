// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/HarmoniaToken.sol";

contract TestSetup is Test {
    HarmoniaToken public harmoniaToken;

    address public owner = address(this);
    address public addr1 = address(0x123);

    function setUp() public virtual {
        harmoniaToken = new HarmoniaToken();
        harmoniaToken.transferOwnership(owner);
    }

    function setUpTests() internal {
        // Additional setup if needed for specific tests
    }
}
