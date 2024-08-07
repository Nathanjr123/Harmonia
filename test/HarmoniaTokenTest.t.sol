// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./TestSetup.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../src/HarmoniaToken.sol";

contract HarmoniaTokenTest is TestSetup {
    uint256 rewardRate = 0.001 ether;
    uint256 rewardRateDecayBps = 200;

    function testInitialSupply() public view {
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
            abi.encodeWithSelector(HarmoniaToken.InvalidAmount.selector, 0)
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
            abi.encodeWithSelector(HarmoniaToken.InvalidAmount.selector, 0)
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
            abi.encodeWithSelector(HarmoniaToken.InvalidAmount.selector, 2000)
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

        // Calculate expected reward per second listened using dynamic reward rate
        uint256 rewardPerSecond = harmoniaToken.getCurrentRewardRate(); // Dynamic reward rate
        uint256 expectedReward = initialSecondsListened * rewardPerSecond;

        // Check initial listening time (should be zero)
        assertEq(harmoniaToken.nftListeningTime(nftId), 0);

        // Update listening time and verify the mapping update
        harmoniaToken.updateListeningTime(nftId, initialSecondsListened);
        assertEq(harmoniaToken.nftListeningTime(nftId), initialSecondsListened);

        // Check rewards after initial update
        uint256 addr1RewardBalanceBeforeUpdate = harmoniaToken.balanceOf(addr1);
        assertEq(addr1RewardBalanceBeforeUpdate, expectedReward);

        // Update listening time again
        uint256 additionalSecondsListened = 1200; // 20 minutes
        uint256 additionalReward = additionalSecondsListened * rewardPerSecond;

        harmoniaToken.updateListeningTime(nftId, additionalSecondsListened);

        // Check updated listening time
        assertEq(
            harmoniaToken.nftListeningTime(nftId),
            initialSecondsListened + additionalSecondsListened
        );

        // Check updated rewards after additional update
        assertEq(
            harmoniaToken.balanceOf(addr1),
            addr1RewardBalanceBeforeUpdate + additionalReward
        );

        vm.stopPrank();
    }
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

        // Calculate expected rewards using dynamic reward rate
        uint256 expectedReward = harmoniaToken._calculateReward(
            secondsListened
        );
        uint256 originalOwnerReward = (expectedReward * 500) / 10000; // 5% to original owner
        uint256 nftOwnerReward = expectedReward - originalOwnerReward;

        // Check rewards without tolerance, exact value matching
        // Use a tolerance of 1 wei to account for minor precision issues
        assertApproxEqAbs(
            harmoniaToken.balanceOf(addr2),
            nftOwnerReward,
            1,
            "NFT owner reward mismatch"
        );
        assertApproxEqAbs(
            harmoniaToken.balanceOf(addr1),
            originalOwnerReward,
            1,
            "Original owner reward mismatch"
        );
    }

    // Test suite for _calculateReward function
    function testCalculateReward() public {
        // Initialize variables
        uint256 initialSecondsListened = 600; // 10 minutes
        uint256 additionalSecondsListened = 1200; // 20 minutes
        // Calculate expected reward using dynamic reward rate
        uint256 expectedReward = initialSecondsListened *
            harmoniaToken.getCurrentRewardRate();
        // Call _calculateReward and capture actual reward
        uint256 actualReward = harmoniaToken._calculateReward(
            initialSecondsListened
        );
        // Assert the actual reward matches the expected reward
        assertEq(
            actualReward,
            expectedReward,
            "Incorrect reward for initial listening time"
        );
        // Calculate expected reward for additional seconds listened
        expectedReward =
            additionalSecondsListened *
            harmoniaToken.getCurrentRewardRate();
        // Call _calculateReward and capture actual reward
        actualReward = harmoniaToken._calculateReward(
            additionalSecondsListened
        );
        // Assert the actual reward matches the expected reward
        assertEq(
            actualReward,
            expectedReward,
            "Incorrect reward after updating listening time"
        );
    }

    function testInitialSetup() public view {
        assertEq(harmoniaToken.totalSupply(), 0);
        assertEq(harmoniaToken.owner(), owner);
    }

    // Test getCurrentRewardRate function to verify dynamic reward rate calculation
    function testGetCurrentRewardRate() public {
        uint256 initialRewardRate = harmoniaToken.rewardRate();
        assertEq(initialRewardRate, 0.001 ether);

        // Simulate passing of time -> 1 interval
        skip(30 days);
        uint256 currentRewardRate = harmoniaToken.getCurrentRewardRate();
        uint256 expectedRewardRate = _getExpectedRewardRate();
        console.log("Current Reward Rate: ", currentRewardRate);
        console.log("Expected Reward Rate: ", expectedRewardRate);

        assertEq(currentRewardRate, expectedRewardRate);

        // Simulate passing of time -> 2 intervals
        skip(30 days);
        currentRewardRate = harmoniaToken.getCurrentRewardRate();
        expectedRewardRate = _getExpectedRewardRate();
        console.log("Current Reward Rate: ", currentRewardRate);
        console.log("Expected Reward Rate: ", expectedRewardRate);

        assertEq(currentRewardRate, expectedRewardRate);

        // Simulate passing of time -> 3 intervals
        skip(30 days);
        currentRewardRate = harmoniaToken.getCurrentRewardRate();
        expectedRewardRate = _getExpectedRewardRate();
        console.log("Current Reward Rate: ", currentRewardRate);
        console.log("Expected Reward Rate: ", expectedRewardRate);
        // 0.00094 ether = 0.001 ether - 6%
        assertEq(currentRewardRate, 0.00094 ether);

        assertEq(currentRewardRate, expectedRewardRate);
    }

    function _getExpectedRewardRate() internal returns (uint256) {
        uint256 intervalsPassed = (block.timestamp -
            harmoniaToken.startTime()) / 30 days;

        if (intervalsPassed == 0) {
            return rewardRate;
        }

        uint256 decayRate = rewardRateDecayBps * intervalsPassed;

        uint256 percentage = (rewardRate * decayRate) / 10000;

        uint256 newRate = rewardRate - percentage;

        return newRate;
    }
}
