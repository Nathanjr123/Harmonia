// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "forge-std/console.sol";
import "./TestSetup.t.sol";
import "forge-std/Vm.sol";

contract CounterTest is TestSetup {
    function test_Increment() public {
        console.log("oo_________kjbnkjo");
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

}
