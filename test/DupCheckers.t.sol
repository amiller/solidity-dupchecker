// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {console} from "forge-std/console.sol";
import {stdStorage, StdStorage, Test} from "forge-std/Test.sol";

import {DupCheckers,BloomDupChecker} from "../src/DupCheckers.sol";

contract DupCheckersTest is Test {
    DupCheckers checker;
    BloomDupChecker bloom;

    function setUp() public {
        checker = new DupCheckers();
        bloom = new BloomDupChecker();
    }

    function generateAddresses(uint count) internal
    pure returns (address[] memory addresses) {
        addresses = new address[](count);
        for (uint i = 0; i < count; i++)
	    addresses[i] = address(uint160(i));
    }

    function testSort() view public {
        address[] memory addresses = generateAddresses(100);
        uint[] memory permutation = checker.getPermutation(addresses);
        for (uint i = 1; i < addresses.length; i++) {
            require(addresses[permutation[i-1]] <= addresses[permutation[i]],
		    "Array is not sorted");
        }
        bool[] memory seen = new bool[](addresses.length);
        for (uint i = 0; i < permutation.length; i++) {
            require(!seen[permutation[i]], "Invalid permutation: duplicate index");
            seen[permutation[i]] = true;
        }
	uint256 startGas;
	// baseline
	startGas = gasleft();
	require(checker.noDuplicates(addresses, permutation));
	console.log("Advice cost");
	console.logUint(startGas - gasleft());

	// using a bloom filter
	startGas = gasleft();
	require(bloom.noDuplicates(addresses, bytes32("0")));
	console.log("Bloom cost");
	console.logUint(startGas - gasleft());
    }

    function testSortBad() view public {
        address[] memory addresses = generateAddresses(100);
	addresses[4] = addresses[20]; // Add a duplicate
        uint[] memory permutation = checker.getPermutation(addresses);
        for (uint i = 1; i < addresses.length; i++) {
            require(addresses[permutation[i-1]] <= addresses[permutation[i]],
		    "Array is not sorted");
        }
        bool[] memory seen = new bool[](addresses.length);
        for (uint i = 0; i < permutation.length; i++) {
            require(!seen[permutation[i]], "Invalid permutation: duplicate index");
            seen[permutation[i]] = true;
        }
	require(!checker.noDuplicates(addresses, permutation));
	require(!bloom.noDuplicates(addresses, bytes32("0")));
    }
}
