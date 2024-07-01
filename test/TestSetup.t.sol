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

    function testInitialSetup() public view {
        assertEq(harmoniaToken.totalSupply(), 0);
        assertEq(harmoniaToken.owner(), owner);
    }

    function testMint() public {
        harmoniaToken.mint(addr1, 1000);
        assertEq(harmoniaToken.balanceOf(addr1), 1000);
    }

    function testBurn() public {
        harmoniaToken.mint(addr1, 1000);
        harmoniaToken.burn(addr1, 500);
        assertEq(harmoniaToken.balanceOf(addr1), 500);
    }
}
