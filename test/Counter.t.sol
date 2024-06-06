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
    string memory gender = "M";
    vm.prank(address(alice)); 
    counter.setProfile(name, age, gender);
    
    // Retrieve stored profile values by calling a view function
    (string memory storedName, uint8 storedAge, string memory storedGender) = counter.getProfile(address(alice));
    
    // Log the retrieved values
    console.logString(storedName); 
    console.logUint(storedAge); // Assuming console.logUint exists to log uint values
    console.logString(storedGender); 

    // Perform assertions
    assertEq(storedName, name);
    assertEq(storedAge, age);
    assertEq(storedGender, gender);
}
 function test_GetProfile() public {
        setUp();
        console.log("Testing GetProfile...");

        string memory name = "Alice";
        uint8 age = 30;
        string memory gender = "F";
        vm.prank(address(alice));
        counter.setProfile(name, age, gender);

        // Retrieve and check the profile
        (string memory retrievedName, uint8 retrievedAge, string memory retrievedGender) = counter.getProfile(address(alice));

        assertEq(retrievedName, name);
        assertEq(retrievedAge, age);
        assertEq(retrievedGender, gender);

        // Check profile for an address that hasn't set a profile
        (retrievedName, retrievedAge, retrievedGender) = counter.getProfile(address(bob));
        assertEq(retrievedName, "");
        assertEq(retrievedAge, 0);
        assertEq(retrievedGender, "");

        // Test with special characters and edge cases
        name = "Bob@123";
        age = 255; // Maximum uint8 value
        gender = "N/A";
        vm.prank(address(bob));
        counter.setProfile(name, age, gender);

        (retrievedName, retrievedAge, retrievedGender) = counter.getProfile(address(bob));

        assertEq(retrievedName, name);
        assertEq(retrievedAge, age);
        assertEq(retrievedGender, gender);

        // Test setting and getting profile for multiple users
        string memory anotherName = "Charlie";
        uint8 anotherAge = 45;
        string memory anotherGender = "M";
        vm.prank(address(charlie));
        counter.setProfile(anotherName, anotherAge, anotherGender);

        (retrievedName, retrievedAge, retrievedGender) = counter.getProfile(address(charlie));
        assertEq(retrievedName, anotherName);
        assertEq(retrievedAge, anotherAge);
        assertEq(retrievedGender, anotherGender);

        // Ensure Alice's profile is still correct
        (retrievedName, retrievedAge, retrievedGender) = counter.getProfile(address(alice));
        assertEq(retrievedName, "Alice");
        assertEq(retrievedAge, 30);
        assertEq(retrievedGender, "F");
    }

}
