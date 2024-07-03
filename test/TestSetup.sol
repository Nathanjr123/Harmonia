// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/HarmoniaToken.sol";

contract TestSetup is Test {
    HarmoniaToken public harmoniaToken;

    address public owner = vm.addr(1);
    address public addr1 = vm.addr(2);

    function setUp() public virtual {
        vm.startPrank(owner);
        harmoniaToken = new HarmoniaToken();
        vm.stopPrank();
    }
}
