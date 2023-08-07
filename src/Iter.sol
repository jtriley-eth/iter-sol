// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.20;

import {Dispatcher} from "src/Dispatcher.sol";
import {Fn, toFn} from "src/Fn.sol";

using { toFn } for function(uint256) pure returns (uint256);

struct Iter {
    Dispatcher dispatcher;
    uint256 index;
    uint256[] inner;
}

using { next, collect, map } for Iter global;

function toIter(uint256[] memory arr) pure returns (Iter memory) {
    return Iter({
        dispatcher: Dispatcher.wrap(0),
        index: 0,
        inner: arr
    });
}

function next(Iter memory self) pure returns (uint256) {
    if (self.index >= self.inner.length) return 0;
    uint256 updated = self.dispatcher.dispatch(self.inner[self.index]);
    self.index += 1;
    return updated;
}

function collect(Iter memory self) pure returns (uint256[] memory res) {
    uint256 i = self.index;
    uint256 len = self.inner.length;
    uint256 resI;
    uint256 resLen = len - i;
    res = new uint256[](resLen);
    while (i < len) {
        res[resI] = self.dispatcher.dispatch(self.inner[i]);
        unchecked {
            i += 1;
            resI += 1;
        }
    }
}

function map(Iter memory self, function(uint256) pure returns (uint256) f) pure returns (Iter memory){
    self.dispatcher = self.dispatcher.append(f.toFn());
    return self;
}
