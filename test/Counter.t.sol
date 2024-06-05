// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import "./TestSetup.t.sol";

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
    console.log("This is a test");

    string memory name = "Nate";
    uint8 age = 30;
    string memory gender = "Male";

    counter.setProfile(name, age, gender);

    (string memory storedName, uint8 storedAge, string memory storedGender) = counter.getProfile(msg.sender);
    console.log("Stored Name:", storedName);

    assertEq(storedName, name);
    assertEq(storedAge, age);
    assertEq(storedGender, gender);
}

}
