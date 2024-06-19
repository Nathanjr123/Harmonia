// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {Counter} from "../src/Counter.sol";

contract TestSetup is Test {
    Counter public counter;
    address alice = vm.addr(2);
    address charlie = vm.addr(3);
    address bob = vm.addr(4);


    function setUp() public {
        counter = new Counter();
        console.log("Counter address: %s", address(counter));
    }
}
