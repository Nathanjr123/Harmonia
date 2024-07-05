// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./TestSetup.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../src/HarmoniaToken.sol";

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
        vm.startPrank(owner);
        vm.expectRevert(
            abi.encodeWithSelector(
                HarmoniaToken.InvalidAddress.selector,
                address(0)
            )
        );
        harmoniaToken.mint(address(0), 1000);
        vm.stopPrank();
    }

    function testMintZeroAmount() public {
        vm.startPrank(owner);
        vm.expectRevert(
            abi.encodeWithSelector(
                HarmoniaToken.InvalidAmount.selector,
                0
            )
        );
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
        vm.expectRevert(
            abi.encodeWithSelector(
                HarmoniaToken.InvalidAmount.selector,
                0
            )
        );
        harmoniaToken.burn(0);
        vm.stopPrank();
    }

    function testBurnExceedsBalance() public {
        vm.startPrank(owner);
        harmoniaToken.mint(addr1, 1000);
        vm.stopPrank();

        vm.startPrank(addr1);
        vm.expectRevert(
            abi.encodeWithSelector(
                HarmoniaToken.InvalidAmount.selector,
                2000
            )
        );
        harmoniaToken.burn(2000);
        vm.stopPrank();
    }

    function testInitialSetup() public {
        assertEq(harmoniaToken.totalSupply(), 0);
        assertEq(harmoniaToken.owner(), owner);
    }
}
