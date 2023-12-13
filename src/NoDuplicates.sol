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
        uint numWords = (size + 255) / 256; // Number of 256-bit words
        bytes32[] memory bloomFilter = new bytes32[](numWords);
        for (uint i = 0; i < addresses.length; i++) {
            bytes32 hash = keccak256(abi.encodePacked(salt, addresses[i]));
            bool anyDiff = false;
            for (uint8 j = 0; j < n_hashes; j++) {
                uint segmentSize = 256 / n_hashes; // Divide the hash into segments
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
