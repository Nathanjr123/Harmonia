// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/HarmoniaToken.sol";
import "../src/HarmoniaNFT.sol";
import "forge-std/console.sol";
 
contract TestSetup is Test {
    HarmoniaToken public harmoniaToken;
    HarmoniaNFT public harmoniaNFT;
    address public owner = vm.addr(1);
    address public addr1 = vm.addr(2);
    

    function setUp() public virtual {
        vm.startPrank(owner);
        harmoniaNFT = new HarmoniaNFT();
        harmoniaToken = new HarmoniaToken(address(harmoniaNFT));
        vm.stopPrank();
        console.log(address(harmoniaToken));
    }
}
