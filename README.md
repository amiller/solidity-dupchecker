## No Duplicates

What's the best way to check that an `address[] memory` (an array of addresses) contains no duplicates?

Expand on possible motivation like checking if a graph cycle is simple. Want to be able to handle long ones.

Here's a cool bloom filter for it:

```solidity
pragma solidity ^0.8;

contract NoDuplicates { 
    uint constant BLOOM_HASHES = 5;
    uint constant BLOOM_FACTOR = 8000;

    function noDuplicates(address[] memory addresses, bytes32 salt)
    public pure returns (bool) {
	return noDuplicates(addresses, salt, BLOOM_HASHES, BLOOM_FACTOR);
    }

    function noDuplicates(address[] memory addresses, bytes32 salt,
			  uint n_hashes, uint factor)
    public pure returns (bool) {
        uint size = factor * addresses.length;
        uint segmentSize = 256 / n_hashes; // Divide the hash into segments
        uint numWords = (size + 255) / 256; // Number of 256-bit words
        bytes32[] memory bloomFilter = new bytes32[](numWords);
        for (uint i = 0; i < addresses.length; i++) {
            bytes32 hash = keccak256(abi.encodePacked(salt, addresses[i]));
            bool anyDiff = false;
            for (uint8 j = 0; j < n_hashes; j++) {
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
```

### Mappings aren't available in Solidity memory
The first approach is to try to use a `mapping` temporary variable. But this approach does not work.

```solidty
function noDuplicates(address[] memory addrs) {
   mapping (address => bool) memory seen;
   ... // visit each address, alerting if it was already seen
}
```

It's possible to use storage, but that is actually expensive. It's also inconvenient, because we'd like to be able to easily use a "read contract" API like we can with ordinary view functions.

### Advice is better than sorting

One insight, and an important general lesson about smart contracts, is to think of verifying rather than computing.

We can take in a permutation as advice, which shows how to permute the array into sorted order. We can easily scan the permutation to check it's in sorted order.

The main downside of this approach is having to provide extra calldata.

### Trying to use large memory isn't great

Solidity expands memory, so we can't just pretend we have a large uninitialized memory as a kind of cheater's mapping. 

### Using a bloom filter

It's non-trivial to use a bloom filter because of grinding and crowding.

### Memory only bloom filter

The best way to do a bloom filter for this problem is to let the prover provide a salt.
This way we can choose a new salt any time we have trouble computing the proof.

HT Jeremy Clark for this suggestion!


## Usage
https://book.getfoundry.sh/

```shell
$ forge test
```
