## No Duplicates

What's the best way to check that an `address[] memory` (an array of addresses) contains no duplicates?

Expand on possible motivation like checking if a graph cycle is simple. Want to be able to handle long ones.

### Mappings aren't available in Solidity memory
The first approach is to try to use a `mapping` temporary variable. But this approach does not work.

It's possible to use storage, but that is actually expensive. It's also inconvenient, because we'd like to be able to easily use a "read contract" API like we can with ordinary view functions.

### Sorting the list is slow

The first main insight, and an important general lesson about smart contracts, is to think of verifying rather than computing.

We can take in a permutation as advice, which shows how to permute the array into sorted order. We can easily scan the permutation to check it's in sorted order.

### Taking advice is inconvenient

Also call data is expensive

### Trying to use large memory isn't great

Solidity expands memory, so we can't just pretend we have a large uninitialized memory as a kind of cheater's mapping. 

### Using a bloom filter

One parameter is whether we can assume the addresses are high entropy or not.

If so we can just use.

Because we are just verifying 

Need to make a cool bloom filter in Solidity?



## Usage
https://book.getfoundry.sh/

```shell
$ forge test
```
