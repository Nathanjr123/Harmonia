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
    address public addr2 = vm.addr(3);
    uint256 public constant MAX_SUPPLY = 500_000_000 ether;
    uint256 public constant BASE_REWARD = 100_000_000 ether;
    uint256 public constant SECONDARY_REWARD = 100_000_000 ether;
    uint256 public constant THIRD_REWARD = 200_000_000 ether;



    

    function setUp() public virtual {
        vm.startPrank(owner);
        harmoniaNFT = new HarmoniaNFT();
        harmoniaToken = new HarmoniaToken(address(harmoniaNFT));
        vm.stopPrank();
        console.log(address(harmoniaToken));
    }
}
