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
}
