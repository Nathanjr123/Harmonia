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
        vm.expectRevert(HarmoniaNFT.InvalidAddress.selector);
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
        vm.expectRevert(
            abi.encodeWithSelector(
                HarmoniaNFT.NotApprovedOrOwner.selector,
                addr2,
                1
            )
        );
        harmoniaNFT.burn(1);
        vm.stopPrank();
    }
    function testBurnNonexistentToken() public {
        vm.startPrank(owner);
        harmoniaNFT.mint(addr1);
        vm.stopPrank();

        // Attempt to burn a token that doesn't exist
        vm.startPrank(addr1);
        vm.expectRevert(
            abi.encodeWithSelector(HarmoniaNFT.NonexistentToken.selector, 999)
        );
        harmoniaNFT.burn(999); // This call should trigger the revert
        vm.stopPrank();
    }

    function testSetNFTOriginalOwner() public {
        // Test minting to addr1 and checking original owner
        vm.startPrank(owner);
        harmoniaNFT.mint(addr1);
        assertEq(
            harmoniaNFT.nftOriginalOwner(1),
            addr1,
            "Original owner should be addr1"
        );
        vm.stopPrank();

        // Test minting to addr2 and checking original owner
        vm.startPrank(owner);
        harmoniaNFT.mint(addr2);
        assertEq(
            harmoniaNFT.nftOriginalOwner(2),
            addr2,
            "Original owner should be addr2"
        );
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

        // Assert that addr1 is the current owner and original owner before transfer
        assertEq(harmoniaNFT.ownerOf(1), addr1, "Initial owner mismatch");
        assertEq(
            harmoniaNFT.nftOriginalOwner(1),
            addr1,
            "Initial original owner mismatch"
        );

        vm.startPrank(addr1);
        harmoniaNFT.transferFrom(addr1, addr2, 1);

        // Assert that the original owner is still addr1
        assertEq(
            harmoniaNFT.nftOriginalOwner(1),
            addr1,
            "Original owner mismatch"
        );

        // Assert that the current owner is now addr2
        assertEq(harmoniaNFT.ownerOf(1), addr2, "Current owner mismatch");
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
