// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./TestSetup.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../src/HarmoniaNFT.sol";

contract HarmoniaNFTTest is TestSetup {

    address public addr2 = vm.addr(3);

    function setUp() public override {
        super.setUp();
    }
//Add test to assert that balace increases after minting
//add tests for tokenexists mapping ensure it's updated correctly
//test that tokenID increases
//Test tokenexists function to ensure it returns the expected results
//check that nft transfers conserves original owner
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
        console.logUint(harmoniaNFT.balanceOf(addr1));
        vm.stopPrank();
        assertEq(harmoniaNFT.balanceOf(addr1),1);

        vm.startPrank(addr1);
        harmoniaNFT.burn(1);
        console.logUint(harmoniaNFT.balanceOf(addr1));
        assertEq(harmoniaNFT.balanceOf(addr1),0);

        vm.stopPrank();

// vm.expectRevert(
//     abi.encodeWithSelector(
//         HarmoniaNFT.NotApprovedOrOwner.selector,
//         msg.sender,
//         1  // Replace with the actual tokenId being tested
//     )
// );        harmoniaNFT.ownerOf(1);
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

    function testSetNFTOriginalOwner() public {
        vm.startPrank(owner);
        harmoniaNFT.mint(addr1);
        vm.stopPrank();

        // Attempt to mint again should not revert because owner is being set correctly
        vm.startPrank(owner);
        harmoniaNFT.mint(addr2);
        vm.stopPrank();
    }
}
