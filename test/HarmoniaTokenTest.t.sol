// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TestSetup.sol";

contract HarmoniaTokenTest is TestSetup {

    function testInitialSupply() public {
        setUp(); // Call setUp from TestSetup
        assertEq(harmoniaToken.totalSupply(), 0);
    }

    function testMint() public {
        setUp(); // Call setUp from TestSetup
        vm.prank(owner); // Set msg.sender to owner
        harmoniaToken.mint(addr1, 10000);
        assertEq(harmoniaToken.balanceOf(addr1), 10000);
    }

    function testMintNotOwner() public {
        setUp(); // Call setUp from TestSetup
        vm.prank(addr1); // Set msg.sender to addr1 (not owner)
        vm.expectRevert("Ownable: caller is not the owner");
        harmoniaToken.mint(addr1, 1000);
    }

   function testBurn() public {
    setUp(); // Call setUp from TestSetup
    vm.prank(owner); // Set msg.sender to owner for minting
    harmoniaToken.mint(addr1, 1000); // Mint tokens to addr1
    vm.prank(addr1); // Set msg.sender to addr1 for burning
    harmoniaToken.burn(500); // Burn tokens from addr1's balance
    assertEq(harmoniaToken.balanceOf(addr1), 500); // Check updated balance of addr1
}

    function testInitialSetup() public {
        setUp(); // Call setUp from TestSetup
        assertEq(harmoniaToken.totalSupply(), 0);
        assertEq(harmoniaToken.owner(), owner);
    }
}
