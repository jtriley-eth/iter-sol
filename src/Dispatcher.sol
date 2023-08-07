// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.20;

import {Fn} from "src/Fn.sol";

type Dispatcher is uint256;

using { length, append, dispatch } for Dispatcher global;

function length(Dispatcher self) pure returns (uint256 l) {
    assembly {
        l := shr(240, self)
    }
}

function append(Dispatcher self, Fn fn) pure returns (Dispatcher) {
    uint256 len = self.length();
    uint256 updated = Dispatcher.unwrap(self) << 16 >> 16;
    updated |= (len + 1) << 240;
    updated |= (fn.toUint256() << (240 - ((len + 1) << 4)));
    return Dispatcher.wrap(updated);
}

function dispatch(Dispatcher self, uint256 element) pure returns (uint256 res) {
    res = element;
    function(uint256) pure returns (uint256) fn;
    uint256 len = self.length();
    uint256 i;

    while (i < len) {
        assembly {
            fn := and(shr(sub(224, shl(4, i)), self), 0xffff)
            i := add(i, 1)
        }
        res = fn(res);
    }
}