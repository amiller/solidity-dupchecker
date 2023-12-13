pragma solidity ^0.8;

import "forge-std/console.sol";

contract BloomDupChecker {
    uint constant BLOOM_HASHES = 2;
    uint constant BLOOM_FACTOR = 8000;

    function noDuplicates(address[] memory addresses, bytes32 salt) public pure returns (bool) {
        uint size = BLOOM_FACTOR * addresses.length;
        uint numWords = (size + 255) / 256; // Number of 256-bit words
        bytes32[] memory bloomFilter = new bytes32[](numWords);
        for (uint i = 0; i < addresses.length; i++) {
            bytes32 hash = keccak256(abi.encodePacked(salt, addresses[i]));
            bool anyDiff = false;
            for (uint8 j = 0; j < BLOOM_HASHES; j++) {
                uint segmentSize = 256 / BLOOM_HASHES; // Divide the hash into segments
                uint shiftBits = j * segmentSize;
                uint idx = uint(uint256(hash) >> shiftBits) % size;
                uint wordIndex = idx / 256;
                uint bitIndex = idx % 256;
                bytes32 mask = bytes32(1 << bitIndex);
                if (bloomFilter[wordIndex] & mask == 0) {
                    anyDiff = true;
                    bloomFilter[wordIndex] |= mask;
                }
            }
            if (!anyDiff) return false;
        }
        return true;
    }
}

contract DupCheckers {

    function noDuplicates(address[] memory original,
			  uint[] memory permutation)
    public pure returns (bool) {
        uint length = original.length;

        // The permutation and original array should have the same length
        if (length != permutation.length) {
            return false;
        }

        // Create an array to track if an index has been seen and to hold the sorted array
        bool[] memory seen = new bool[](length);
        address[] memory sorted = new address[](length);

        // Apply the permutation and check if it's valid
        for (uint i = 0; i < length; i++) {
            uint permIndex = permutation[i];

            // Check if the permutation index is valid and not seen before
            if (permIndex >= length || seen[permIndex]) {
                return false;
            }

            seen[permIndex] = true; // Mark this index as seen
            sorted[i] = original[permIndex]; // Apply permutation to sort the array
        }

        // Check for duplicates in the sorted array
        for (uint i = 1; i < length; i++) {
            if (sorted[i] == sorted[i - 1]) {
                return false;
            }
        }

        return true;
    }

    function getPermutation(address[] memory arr) public pure returns (uint[] memory) {
        uint length = arr.length;
        uint[] memory permutation = new uint[](length);
        address[] memory sortedArr = new address[](length);

        // Initialize the permutation and sortedArr
        for (uint i = 0; i < length; i++) {
            permutation[i] = i;
            sortedArr[i] = arr[i];
        }

        // Perform a simple bubble sort on the sortedArr
        for (uint i = 0; i < length; i++) {
            for (uint j = 0; j < length - i - 1; j++) {
                if (sortedArr[j] > sortedArr[j + 1]) {
                    // Swap elements in the sortedArr
                    address temp = sortedArr[j];
                    sortedArr[j] = sortedArr[j + 1];
                    sortedArr[j + 1] = temp;

                    // Swap the corresponding indices in the permutation
                    uint tempIndex = permutation[j];
                    permutation[j] = permutation[j + 1];
                    permutation[j + 1] = tempIndex;
                }
            }
        }

        return permutation;
    }
}
