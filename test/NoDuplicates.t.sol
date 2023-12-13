// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {console} from "forge-std/console.sol";
import {stdStorage, StdStorage, Test} from "forge-std/Test.sol";

import {NoDuplicates} from "../src/NoDuplicates.sol";

contract NoDuplicatesTest is Test {
    NoDuplicates checker;

        function generateAddresses(uint count) internal
    pure returns (address[] memory addresses) {
        addresses = new address[](count);
        for (uint i = 0; i < count; i++) addresses[i] = address(uint160(i));
    }

    function setUp() public {
        checker = new NoDuplicates();
    }

    function testRange() view public {
	address[] memory addresses = generateAddresses(10);
	uint startGas;
	startGas = gasleft();
	require(checker.noDuplicates(addresses, bytes32("0")));
	console.log("No Duplicates cost:");
	console.logUint(startGas - gasleft());
    }

    function testBasic() view public {
        address[] memory addresses = generateAddresses(10);
	require(checker.noDuplicates(addresses, bytes32("0")));	
	addresses[4] = addresses[9];
	require(!checker.noDuplicates(addresses, bytes32("0")));
    }    
}
