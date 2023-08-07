# Iter

Lazy evaluated iterators in Solidity.

We wrap a `uint256` memory array and enable up to `15` different functions to map over each element.

Note that due to laziness, calling `.map` does not loop over the iterator immediately.
The iterator may only advance by one with the `.next` method and by the remainder of the iterator
with the `.collect` method.

## Usage

```bash
forge install jtriley-eth/iter-sol
```

```solidity
import {Iter, toIter} from "lib/iter-sol/src/Lib.sol";

using { toIter } for uint256[];
// -- snip --

function addOneDoubleThenSubOne(uint256[] meomry arr) pure returns (uint256[] memory) {
    return arr.toIter()
        .map(addOne)
        .map(double)
        .map(subOne)
        .collect();
}

// -- utilities --

function double(uint256 x) pure returns (uint256) {
    return x * 2;
}

function addOne(uint256 x) pure returns (uint256) {
    return x + 1;
}

function subOne(uint256 x) pure returns (uint256) {
    return x - 1;
}
```

## API

### `Iter`

Main iterator structure, wraps the array.

#### `uint256[].toIter`

Converts a `uint256[]` into an `Iter`.

#### `Iter.next`

Advances the iterator by one, applying all mapped functions over the element.

> Note: returns zero if empty

#### `Iter.collect`

Advances the iterator to the end of the inner array, applying all mapped functions over each element
and collecting the result into a `uint256[]`.

#### `Iter.map`

Maps a single internal function over the iterator.

Internal function signature _must_ be as follows.

```solidity
function(uint256) pure returns (uint256)
```

### `Fn`

#### `function(uint256) pure returns (uint256).toFn`

Converts the function to a generalized `Fn` type.

#### `Fn.toUint256`

Converts the `Fn` type to `uint256`

### `Dispatcher`

#### `Dispathcer.length`

Gets the length of the dispatcher. This is not the number of elements in the iterator, rather it is
the number of functions to map over.

#### `Dispatcher.append`

Appends another function to the dispatcher. This is not necessary to access from the outside, this
is for the `Iter.map` method.

#### `Dispatcher.dispatch`

Loops each function and calls each against a single element.
