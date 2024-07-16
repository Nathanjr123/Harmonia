// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./TestSetup.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../src/HarmoniaNFT.sol";
import "../src/HarmoniaToken.sol";


contract HarmoniaNFTTest is TestSetup {


    function testMint() public {
        vm.startPrank(owner);
        harmoniaNFT.mint(addr1);
        assertEq(harmoniaNFT.ownerOf(1), addr1);
        assertEq(harmoniaNFT.nftOriginalOwner(1), addr1);
        vm.stopPrank();
    }

    function testMintToZeroAddress() public {
        vm.startPrank(owner);
        vm.expectRevert(abi.encodeWithSelector(HarmoniaNFT.InvalidAddress.selector));
        harmoniaNFT.mint(address(0));
        vm.stopPrank();
    }

    function testBurn() public {
        vm.startPrank(owner);
        harmoniaNFT.mint(addr1);
        vm.stopPrank();
        assertEq(harmoniaNFT.balanceOf(addr1), 1);

        vm.startPrank(addr1);
        harmoniaNFT.burn(1);
        assertEq(harmoniaNFT.balanceOf(addr1), 0);
        vm.stopPrank();
    }

    function testBurnNotOwner() public {
        vm.startPrank(owner);
        harmoniaNFT.mint(addr1);
        vm.stopPrank();

        vm.startPrank(addr2);
        vm.expectRevert(abi.encodeWithSelector(HarmoniaNFT.NotApprovedOrOwner.selector, addr2, 1));
        harmoniaNFT.burn(1);
        vm.stopPrank();
    }

    function testSetNFTOriginalOwner() public {
        vm.startPrank(owner);
        harmoniaNFT.mint(addr1);
        vm.stopPrank();

        // Attempt to mint again should not revert because owner is being set correctly
        vm.startPrank(owner);
        harmoniaNFT.mint(addr1);
        vm.stopPrank();
    }

    function testBalanceIncreasesAfterMinting() public {
        vm.startPrank(owner);
        harmoniaNFT.mint(addr1);
        assertEq(harmoniaNFT.balanceOf(addr1), 1);
        harmoniaNFT.mint(addr1);
        assertEq(harmoniaNFT.balanceOf(addr1), 2);
        vm.stopPrank();
    }

function testTokenExistsFunction() public {
    uint256 nftId = 1;

    vm.startPrank(owner);
    harmoniaNFT.mint(addr1);
    vm.stopPrank();

    vm.startPrank(addr1);
    // Check if the token exists
    bool exists = harmoniaNFT.tokenExists(nftId);
    assertTrue(exists);
    vm.stopPrank();
}



    function testNFTTransfersConserveOriginalOwner() public {
        vm.startPrank(owner);
        harmoniaNFT.mint(addr1);
        vm.stopPrank();

        vm.startPrank(addr1);
        harmoniaNFT.transferFrom(addr1, addr2, 1);
        assertEq(harmoniaNFT.nftOriginalOwner(1), addr1);
        vm.stopPrank();
    }

    function testTokenIdIncreases() public {
        vm.startPrank(owner);
        harmoniaNFT.mint(addr1);
        assertEq(harmoniaNFT.currentTokenId(), 2);
        harmoniaNFT.mint(addr1);
        assertEq(harmoniaNFT.currentTokenId(), 3);
        vm.stopPrank();
    }
}
