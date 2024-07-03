// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TestSetup.sol";

contract HarmoniaTokenTest is TestSetup {

    function testInitialSupply() public {
        assertEq(harmoniaToken.totalSupply(), 0);
    }

function testMint() public {
    vm.startPrank(owner); // Set msg.sender to owner
    
    // Check initial balance
    assertEq(harmoniaToken.balanceOf(addr1), 0);
    
    // Mint tokens
    harmoniaToken.mint(addr1, 10000);
    
    // Check updated balance
    assertEq(harmoniaToken.balanceOf(addr1), 10000);
    
    vm.stopPrank();
}


    function testMintNotOwner() public {
        vm.startPrank(addr1);
        vm.expectRevert("Ownable: caller is not the owner");
        harmoniaToken.mint(addr1, 1000);
        vm.stopPrank();
    }

    function testMintToZeroAddress() public {
        vm.startPrank(owner);
        vm.expectRevert("HarmoniaToken: mint to the zero address");
        harmoniaToken.mint(address(0), 1000);
        vm.stopPrank();
    }

    function testMintZeroAmount() public {
        vm.startPrank(owner);
        vm.expectRevert("HarmoniaToken: mint amount must be greater than zero");
        harmoniaToken.mint(addr1, 0);
        vm.stopPrank();
    }

    function testBurn() public {
        vm.startPrank(owner);
        harmoniaToken.mint(addr1, 1000);
        vm.stopPrank();

        vm.startPrank(addr1);
        harmoniaToken.burn(500);
        assertEq(harmoniaToken.balanceOf(addr1), 500);
        vm.stopPrank();
    }

    function testBurnZeroAmount() public {
        vm.startPrank(owner);
        harmoniaToken.mint(addr1, 1000);
        vm.stopPrank();

        vm.startPrank(addr1);
        vm.expectRevert("HarmoniaToken: burn amount must be greater than zero");
        harmoniaToken.burn(0);
        vm.stopPrank();
    }

    function testBurnExceedsBalance() public {
        vm.startPrank(owner);
        harmoniaToken.mint(addr1, 1000);
        vm.stopPrank();

        vm.startPrank(addr1);
        vm.expectRevert("HarmoniaToken: burn amount exceeds balance");
        harmoniaToken.burn(2000);
        vm.stopPrank();
    }

    function testInitialSetup() public {
        assertEq(harmoniaToken.totalSupply(), 0);
        assertEq(harmoniaToken.owner(), owner);
        
        // Check that name and symbol are correct
        assertEq(harmoniaToken.name(), "Harmonia");
        assertEq(harmoniaToken.symbol(), "HRM"); 
    }
}
