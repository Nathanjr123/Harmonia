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
    
// Test updating listening time and reward distribution
function testUpdateListeningTime() public {
    vm.startPrank(owner);

    // Set up initial listening time and verify initial balances
    uint256 nftId = 1;
    harmoniaNFT.mint(addr1);
    uint256 initialSecondsListened = 600; // 10 minutes
    harmoniaToken.updateListeningTime(nftId, initialSecondsListened);

    uint256 expectedReward = (initialSecondsListened * 1 ether * 17) / 10000; // 1/600 as basis points
    uint256 originalOwnerReward = (expectedReward * 500) / 10000; // 5% to original owner
    uint256 nftOwnerReward = expectedReward - originalOwnerReward;

    // Check rewards
    assertApproxEqRel(harmoniaToken.balanceOf(addr1), nftOwnerReward, 0.06 ether);  // Adjusted for approximation
    assertApproxEqRel(harmoniaToken.balanceOf(owner), originalOwnerReward, 0.06 ether);  // Adjusted for approximation

    // Update listening time again
    uint256 additionalSecondsListened = 1200; // 20 minutes
    harmoniaToken.updateListeningTime(nftId, additionalSecondsListened);

    uint256 totalSecondsListened = initialSecondsListened + additionalSecondsListened;
    uint256 totalReward = (totalSecondsListened * 1 ether * 17) / 10000; // Combined rewards
    originalOwnerReward = (totalReward * 500) / 10000; // 5% to original owner
    nftOwnerReward = totalReward - originalOwnerReward;

    // Check updated rewards
    assertApproxEqRel(harmoniaToken.balanceOf(addr1), nftOwnerReward, 0.06 ether);  // Adjusted for approximation
    assertApproxEqRel(harmoniaToken.balanceOf(owner), originalOwnerReward, 0.06 ether);  // Adjusted for approximation

    vm.stopPrank();
}
// Test the _rewardNFT function
    function testRewardNFT() public {
        vm.startPrank(owner);

        // Mint an NFT and set initial listening time
        uint256 nftId = 1;
        harmoniaNFT.mint(addr1);
        uint256 secondsListened = 600; // 10 minutes
        harmoniaToken.updateListeningTime(nftId, secondsListened);

        // Calculate expected rewards
        uint256 expectedReward = (secondsListened * 1 ether * 17) / 10000; // 1/600 as basis points
        uint256 originalOwnerReward = (expectedReward * 500) / 10000; // 5% to original owner
        uint256 nftOwnerReward = expectedReward - originalOwnerReward;

        // Reward NFT
        harmoniaToken._rewardNFT(nftId, secondsListened);

        // Check rewards
        uint256 tolerance = 1 ether / 100; // 1% tolerance
        assertApproxEqRel(harmoniaToken.balanceOf(addr1), nftOwnerReward, tolerance);
        assertApproxEqRel(harmoniaToken.balanceOf(owner), originalOwnerReward, tolerance);

        vm.stopPrank();
    }
// Test reward calculation
function testCalculateReward() public {
    // Define the seconds listened
    uint256 secondsListened = 600; // 10 minutes

    // Calculate the expected reward
    uint256 rewardBasisPoints = 17; // 1/600 as basis points
    uint256 expectedReward = (secondsListened * 1 ether * rewardBasisPoints) / 10000;

    // Call the _calculateReward function and get the actual reward
    uint256 actualReward = harmoniaToken._calculateReward(secondsListened);

    // Assert the rewards with some tolerance for minor precision issues
    assertApproxEqRel(actualReward, expectedReward, 1e15);  // Adjust the tolerance if needed
}

    function testInitialSetup() public {
        assertEq(harmoniaToken.totalSupply(), 0);
        assertEq(harmoniaToken.owner(), owner);
    }
}