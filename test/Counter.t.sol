// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "forge-std/console.sol";
import "./TestSetup.t.sol";
import "forge-std/Vm.sol";

contract CounterTest is TestSetup {
    function test_Increment() public {
        assertEq(counter.getNumber(), 0);
        counter.increment();
        assertEq(counter.getNumber(), 1);
    }

    function test_SetNumber() public {
        counter.setNumber(42);
        assertEq(counter.getNumber(), 42);
    }

    function testFuzz_SetNumber(uint256 x) public {
        counter.setNumber(x);
        assertEq(counter.getNumber(), x);
    }

    function test_SetProfile() public {
        setUp();
        console.log("Testing SetProfile...");
        
        string memory name = "Nate";
        uint8 age = 100;
        bool gender = true;
        string memory country = "USA";
        Counter.Interest interest = Counter.Interest.Sport;

        vm.prank(address(alice)); 
        counter.setProfile(name, age, gender, country, interest);
        
        // Retrieve stored profile values by calling a view function
        (
            string memory storedName,
            uint8 storedAge,
            bool storedGender,
            string memory storedCountry,
            Counter.Interest storedInterest
        ) = counter.getProfile(address(alice));
        
        // Log the retrieved values
        console.logString(storedName); 
        console.logUint(storedAge);
        console.logBool(storedGender);
        console.logString(storedCountry);
        console.logUint(uint(storedInterest)); // Convert enum to uint for logging

        // Perform assertions
        assertEq(storedName, name);
        assertEq(storedAge, age);
        assertEq(storedGender, gender);
        assertEq(storedCountry, country);
        assertEq(uint(storedInterest), uint(interest)); // Compare enum as uint
    }

    function test_MatchWith() public {
    setUp();
    console.log("Testing MatchWith...");
    
    // Set profiles for alice and bob
    string memory nameAlice = "Alice";
    uint8 ageAlice = 30;
    bool genderAlice = false;
    string memory countryAlice = "USA";
    Counter.Interest interestAlice = Counter.Interest.Books;

    string memory nameBob = "Bob";
    uint8 ageBob = 40;
    bool genderBob = true;
    string memory countryBob = "USA";
    Counter.Interest interestBob = Counter.Interest.Nature;

    vm.prank(address(alice)); 
    counter.setProfile(nameAlice, ageAlice, genderAlice, countryAlice, interestAlice);
    
    vm.prank(address(bob)); 
    counter.setProfile(nameBob, ageBob, genderBob, countryBob, interestBob);

    // Perform match
    vm.prank(address(alice));
    console.log("Matching Alice with Bob...");
    counter.matchWith(address(bob));

    // Check match
    bool hasMatched = counter.hasMatched(address(alice), address(bob));
    assertTrue(hasMatched);

    // Attempt to match with self
   // vm.expectRevert("You cannot match with yourself");
   // console.log("Attempting to match Alice with herself...");
    //counter.matchWith(address(alice));
}


}
