// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TestSetup.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract HarmoniaTokenTest is TestSetup {

    function testInitialSupply() public {
        setUp();
        assertEq(harmoniaToken.totalSupply(), 0);
    }

    function testMint() public {
        setUp(); // Call setUp from TestSetup
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
        setUp();
        vm.startPrank(addr1);
        vm.expectRevert(
            abi.encodeWithSelector(
                Ownable.OwnableUnauthorizedAccount.selector,
                addr1
            )
        );
        harmoniaToken.mint(addr1, 1000);
        vm.stopPrank();
    }

    function testMintToZeroAddress() public {
        setUp();
        vm.startPrank(owner);
        vm.expectRevert("HarmoniaToken: mint to the zero address");
        harmoniaToken.mint(address(0), 1000);
        vm.stopPrank();
    }

    function testMintZeroAmount() public {
        setUp();
        vm.startPrank(owner);
        vm.expectRevert("HarmoniaToken: mint amount must be greater than zero");
        harmoniaToken.mint(addr1, 0);
        vm.stopPrank();
    }

    function testBurn() public {
        setUp();
        vm.startPrank(owner);
        harmoniaToken.mint(addr1, 1000);
        vm.stopPrank();

        vm.startPrank(addr1);
        harmoniaToken.burn(500);
        assertEq(harmoniaToken.balanceOf(addr1), 500);
        vm.stopPrank();
    }

    function testBurnZeroAmount() public {
        setUp();
        vm.startPrank(owner);
        harmoniaToken.mint(addr1, 1000);
        vm.stopPrank();

        vm.startPrank(addr1);
        vm.expectRevert("HarmoniaToken: burn amount must be greater than zero");
        harmoniaToken.burn(0);
        vm.stopPrank();
    }

    function testBurnExceedsBalance() public {
        setUp();
        vm.startPrank(owner);
        harmoniaToken.mint(addr1, 1000);
        vm.stopPrank();

        vm.startPrank(addr1);
        vm.expectRevert("HarmoniaToken: burn amount exceeds balance");
        harmoniaToken.burn(2000);
        vm.stopPrank();
    }

    function testInitialSetup() public  {
        setUp();
        assertEq(harmoniaToken.totalSupply(), 0);
        assertEq(harmoniaToken.owner(), owner);
    }
}
