// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "forge-std/console.sol";
import "./TestSetup.t.sol";
import "forge-std/Vm.sol";

contract CounterTest is TestSetup {
    
    function test_SetProfile() public {
        setUp();
        console.log("Testing SetProfile...");

        // Test setting profile for Alice
        string memory name = "Nate";
        uint8 age = 100;
        bool gender = true;
        string memory country = "USA";
        Counter.Interest interest = Counter.Interest.Sport;

        vm.prank(address(alice)); 
        counter.setProfile(name, age, gender, country, interest);
        
        (
            string memory storedName,
            uint8 storedAge,
            bool storedGender,
            string memory storedCountry,
            Counter.Interest storedInterest
        ) = counter.profiles(address(alice));

        console.logString(storedName); 
        console.logUint(storedAge);
        console.logBool(storedGender);
        console.logString(storedCountry);
        console.logUint(uint(storedInterest)); // Convert enum to uint for logging

        assertEq(storedName, name);
        assertEq(storedAge, age);
        assertEq(storedGender, gender);
        assertEq(storedCountry, country);
        assertEq(uint(storedInterest), uint(interest)); // Compare enum as uint
    }

    function test_SetMultipleProfiles() public {
        setUp();
        console.log("Testing SetMultipleProfiles...");

        // Test setting profile for Alice
        string memory nameAlice = "Alice";
        uint8 ageAlice = 30;
        bool genderAlice = false;
        string memory countryAlice = "USA";
        Counter.Interest interestAlice = Counter.Interest.Books;

        vm.prank(address(alice)); 
        counter.setProfile(nameAlice, ageAlice, genderAlice, countryAlice, interestAlice);

        // Test setting profile for Bob
        string memory nameBob = "Bob";
        uint8 ageBob = 40;
        bool genderBob = true;
        string memory countryBob = "USA";
        Counter.Interest interestBob = Counter.Interest.Nature;

        vm.prank(address(bob)); 
        counter.setProfile(nameBob, ageBob, genderBob, countryBob, interestBob);

        (
            string memory storedNameAlice,
            uint8 storedAgeAlice,
            bool storedGenderAlice,
            string memory storedCountryAlice,
            Counter.Interest storedInterestAlice
        ) = counter.profiles(address(alice));

        (
            string memory storedNameBob,
            uint8 storedAgeBob,
            bool storedGenderBob,
            string memory storedCountryBob,
            Counter.Interest storedInterestBob
        ) = counter.profiles(address(bob));

        assertEq(storedNameAlice, nameAlice);
        assertEq(storedAgeAlice, ageAlice);
        assertEq(storedGenderAlice, genderAlice);
        assertEq(storedCountryAlice, countryAlice);
        assertEq(uint(storedInterestAlice), uint(interestAlice)); // Compare enum as uint

        assertEq(storedNameBob, nameBob);
        assertEq(storedAgeBob, ageBob);
        assertEq(storedGenderBob, genderBob);
        assertEq(storedCountryBob, countryBob);
        assertEq(uint(storedInterestBob), uint(interestBob)); // Compare enum as uint
    }

    function test_MatchWith() public {
        setUp();
        console.log("Testing MatchWith...");
        
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

        vm.prank(address(alice));
        console.log("Matching Alice with Bob...");
        counter.matchWith(address(bob));

        bool hasMatched = counter.hasMatched(address(alice), address(bob));
        assertTrue(hasMatched);

        // Uncomment the following lines if you want to test self-matching reversion
        // vm.expectRevert("You cannot match with yourself");
        // console.log("Attempting to match Alice with herself...");
        // counter.matchWith(address(alice));
    }

    function test_MultipleMatches() public {
        setUp();
        console.log("Testing Multiple Matches...");

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

        string memory nameCharlie = "Charlie";
        uint8 ageCharlie = 25;
        bool genderCharlie = true;
        string memory countryCharlie = "Canada";
        Counter.Interest interestCharlie = Counter.Interest.Sport;

        vm.prank(address(alice)); 
        counter.setProfile(nameAlice, ageAlice, genderAlice, countryAlice, interestAlice);
        
        vm.prank(address(bob)); 
        counter.setProfile(nameBob, ageBob, genderBob, countryBob, interestBob);

        vm.prank(address(charlie)); 
        counter.setProfile(nameCharlie, ageCharlie, genderCharlie, countryCharlie, interestCharlie);

        vm.prank(address(alice));
        console.log("Matching Alice with Bob...");
        counter.matchWith(address(bob));

        vm.prank(address(alice));
        console.log("Matching Alice with Charlie...");
        counter.matchWith(address(charlie));

        bool hasMatchedWithBob = counter.hasMatched(address(alice), address(bob));
        bool hasMatchedWithCharlie = counter.hasMatched(address(alice), address(charlie));

        assertTrue(hasMatchedWithBob);
        assertTrue(hasMatchedWithCharlie);
    }

    function test_ConnectWith() public {
        setUp();
        console.log("Testing ConnectWith...");

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

        vm.prank(address(alice));
        console.log("Connecting Alice with Bob...");
        counter.connectWith(address(bob));

        bool isConnected = counter.isConnectedWith(address(alice), address(bob));
        assertTrue(isConnected);

        // Uncomment the following lines if you want to test self-connection reversion
        // vm.expectRevert("You cannot connect with yourself");
        // console.log("Attempting to connect Alice with herself...");
        // counter.connectWith(address(alice));
    }

    function test_MultipleConnections() public {
        setUp();
        console.log("Testing Multiple Connections...");

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

        string memory nameCharlie = "Charlie";
        uint8 ageCharlie = 25;
        bool genderCharlie = true;
        string memory countryCharlie = "Canada";
        Counter.Interest interestCharlie = Counter.Interest.Sport;

        vm.prank(address(alice)); 
        counter.setProfile(nameAlice, ageAlice, genderAlice, countryAlice, interestAlice);
        
        vm.prank(address(bob)); 
        counter.setProfile(nameBob, ageBob, genderBob, countryBob, interestBob);

        vm.prank(address(charlie)); 
        counter.setProfile(nameCharlie, ageCharlie, genderCharlie, countryCharlie, interestCharlie);

        vm.prank(address(alice));
        console.log("Connecting Alice with Bob...");
        counter.connectWith(address(bob));

        vm.prank(address(alice));
        console.log("Connecting Alice with Charlie...");
        counter.connectWith(address(charlie));

        bool isConnectedWithBob = counter.isConnectedWith(address(alice), address(bob));
        bool isConnectedWithCharlie = counter.isConnectedWith(address(alice), address(charlie));

        assertTrue(isConnectedWithBob);
        assertTrue(isConnectedWithCharlie);
    }

    function test_InvalidOperations() public {
        setUp();
        console.log("Testing Invalid Operations...");

        string memory nameAlice = "Alice";
        uint8 ageAlice = 30;
        bool genderAlice = false;
        string memory countryAlice = "USA";
        Counter.Interest interestAlice = Counter.Interest.Books;

        vm.prank(address(alice)); 
        counter.setProfile(nameAlice, ageAlice, genderAlice, countryAlice, interestAlice);

        // Test invalid profile setting
        string memory emptyName = "";
        uint8 invalidAge = 255; // Assuming age limit is < 255
        string memory emptyCountry = "";

        vm.expectRevert("Invalid name");
        counter.setProfile(emptyName, ageAlice, genderAlice, countryAlice, interestAlice);

        vm.expectRevert("Invalid age");
        counter.setProfile(nameAlice, invalidAge, genderAlice, countryAlice, interestAlice);

        vm.expectRevert("Invalid country");
        counter.setProfile(nameAlice, ageAlice, genderAlice, emptyCountry, interestAlice);

        // Test self-matching and self-connection
        vm.expectRevert("You cannot match with yourself");
        vm.prank(address(alice));
        counter.matchWith(address(alice));

        vm.expectRevert("You cannot connect with yourself");
        vm.prank(address(alice));
        counter.connectWith(address(alice));
    }

    function test_RevertWithoutProfile() public {
        setUp();
        console.log("Testing operations without profile...");

        // Attempt to match without profile
        vm.expectRevert("Profile does not exist");
        vm.prank(address(alice));
        counter.matchWith(address(bob));

        // Attempt to connect without profile
        vm.expectRevert("Profile does not exist");
        vm.prank(address(alice));
        counter.connectWith(address(bob));
    }
}
