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
    uint256 initialSecondsListened = 1; // 1 second baseline

    // Check initial listening time (should be zero)
    assertEq(harmoniaToken.nftListeningTime(nftId), 0);

    // Update listening time and verify the mapping update
    harmoniaToken.updateListeningTime(nftId, initialSecondsListened);
    assertEq(harmoniaToken.nftListeningTime(nftId), initialSecondsListened);

    // Calculate expected reward per second listened
    uint256 rewardPerSecond = 0.001 ether ; // 0.001 Harmonia per second

    uint256 expectedReward = initialSecondsListened * rewardPerSecond;
    uint256 originalOwnerReward = (expectedReward * 500) / 10000; // 5% to original owner
    uint256 nftOwnerReward = expectedReward - originalOwnerReward;

    // Check rewards after initial update
    assertEq(harmoniaToken.balanceOf(addr1), expectedReward);
    assertEq(harmoniaToken.balanceOf(owner), 0); // Owner is not the original owner in this case

    // Update listening time again
    uint256 additionalSecondsListened = 1200; // 20 minutes
    harmoniaToken.updateListeningTime(nftId, additionalSecondsListened);

    // Calculate total reward after additional listening time
    uint256 additionalReward = additionalSecondsListened * rewardPerSecond;
    expectedReward = (initialSecondsListened + additionalSecondsListened) * rewardPerSecond;
    originalOwnerReward = (expectedReward * 500) / 10000; // 5% to original owner
    nftOwnerReward = expectedReward - originalOwnerReward;

    // Check updated listening time
    assertEq(harmoniaToken.nftListeningTime(nftId), initialSecondsListened + additionalSecondsListened);

    // Check updated rewards after additional update
    assertEq(harmoniaToken.balanceOf(addr1), expectedReward);
    assertEq(harmoniaToken.balanceOf(owner), 0); // Owner is not the original owner in this case

    vm.stopPrank();
}

// Test rewarding an NFT owner and the original owner
function testRewardNFT() public {
    // Start prank as the owner
    vm.startPrank(owner);

    // Mint an NFT to addr1
    uint256 nftId = 1;
    harmoniaNFT.mint(addr1);

    // Stop prank as the owner
    vm.stopPrank();

    // Start prank as addr1 to approve the transfer
    vm.startPrank(addr1);
    harmoniaNFT.approve(owner, nftId);
    vm.stopPrank();

    // Start prank as the owner to transfer the NFT to addr2
    vm.startPrank(owner);
    harmoniaNFT.transferFrom(addr1, addr2, nftId);
    vm.stopPrank();

    // Start prank as the owner to call _rewardNFT
    vm.startPrank(owner);
    uint256 secondsListened = 1; // 1 second baseline
    harmoniaToken._rewardNFT(nftId, secondsListened);
    vm.stopPrank();

    // Calculate expected rewards
    uint256 expectedReward = harmoniaToken._calculateReward(secondsListened);
    uint256 originalOwnerReward = (expectedReward * 500) / 10000; // 5% to original owner
    uint256 nftOwnerReward = expectedReward - originalOwnerReward;

    // Check rewards without tolerance, exact value matching
    assertEq(harmoniaToken.balanceOf(addr2), nftOwnerReward, "NFT owner reward mismatch");
    assertEq(harmoniaToken.balanceOf(addr1), originalOwnerReward, "Original owner reward mismatch");
}



// Test suite for _calculateReward function
function testCalculateReward() public {
    // Initialize variables
    uint256 rewardRate = 0.001 ether;
    uint256 initialSecondsListened = 600; // 10 minutes
    uint256 additionalSecondsListened = 1200; // 20 minutes
    uint256 totalListeningTime = initialSecondsListened + additionalSecondsListened;

    // Test case 1: Calculate reward for initial listening time
    {
       
        // Calculate expected reward
        uint256 expectedReward = initialSecondsListened * rewardRate;

        // Call _calculateReward and capture actual reward
        uint256 actualReward = harmoniaToken._calculateReward(initialSecondsListened);

        // Assert the actual reward matches the expected reward
        assertEq(actualReward, expectedReward, "Incorrect reward for initial listening time");
    }

    // Test case 2: Calculate reward after updating listening time
    {
        // Calculate expected reward after additional listening time
        uint256 expectedReward = totalListeningTime * rewardRate;

        // Call _calculateReward again after updating listening time
        uint256 actualReward = harmoniaToken._calculateReward(initialSecondsListened + additionalSecondsListened);

        // Assert the actual reward matches the expected reward
        assertEq(actualReward, expectedReward, "Incorrect reward after updating listening time");
    }
}


    function testInitialSetup() public {
        assertEq(harmoniaToken.totalSupply(), 0);
        assertEq(harmoniaToken.owner(), owner);
    }
}