// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.20;

type Fn is uint16;

using { toUint256 } for Fn global;

function toFn(function(uint256) pure returns (uint256) f) pure returns (Fn fn) {
    assembly {
        fn := f
    }
}

function toUint256(Fn fn) pure returns (uint256) {
    return uint256(Fn.unwrap(fn));
}
