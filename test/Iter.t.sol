// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.20;

import {Iter, toIter, Fn, toFn, Dispatcher} from "src/Lib.sol";
import "lib/forge-std/src/Test.sol";

using {toIter} for uint256[];
using {toFn} for function(uint256) pure returns (uint256);

contract IterTest is Test {
    function testEmpty() public {
        uint256[] memory arr = new uint256[](0);
        Iter memory iter = arr.toIter();

        assertEq(Dispatcher.unwrap(iter.dispatcher), 0);
        assertEq(iter.index, 0);
        assertEq(iter.inner.length, 0);
    }

    function testInitialState() public {
        Iter memory iter = __defaultArr().toIter();

        assertEq(Dispatcher.unwrap(iter.dispatcher), 0);
        assertEq(iter.index, 0);
        assertEq(iter.inner.length, 3);
        assertEq(iter.inner[0], 1);
        assertEq(iter.inner[1], 2);
        assertEq(iter.inner[2], 3);
    }

    function testFuzzInitialState(uint256[] memory arr) public {
        Iter memory iter = arr.toIter();

        assertEq(Dispatcher.unwrap(iter.dispatcher), 0);
        assertEq(iter.index, 0);
        assertEq(iter.inner.length, arr.length);
        for (uint256 i; i < arr.length; i++) {
            assertEq(iter.inner[i], arr[i]);
        }
    }

    function testSingleMap() public {
        Iter memory iter = __defaultArr().toIter().map(__double);

        uint256 expectedDispatcher = (1 << 240) | (__double.toFn().toUint256() << 224);

        assertEq(Dispatcher.unwrap(iter.dispatcher), expectedDispatcher);
        assertEq(iter.index, 0);
        assertEq(iter.inner.length, 3);
        assertEq(iter.inner[0], 1);
        assertEq(iter.inner[1], 2);
        assertEq(iter.inner[2], 3);
    }

    function testDoubleMap() public {
        Iter memory iter = __defaultArr().toIter().map(__double).map(__triple);

        uint256 expectedDispatcher =
            (2 << 240) | (__double.toFn().toUint256() << 224) | (__triple.toFn().toUint256() << 208);

        assertEq(Dispatcher.unwrap(iter.dispatcher), expectedDispatcher);
        assertEq(iter.index, 0);
        assertEq(iter.inner.length, 3);
        assertEq(iter.inner[0], 1);
        assertEq(iter.inner[1], 2);
        assertEq(iter.inner[2], 3);
    }

    function testSingleMapNext() public {
        Iter memory iter = __defaultArr().toIter().map(__double);

        assertEq(iter.next(), 2);
        assertEq(iter.next(), 4);
        assertEq(iter.next(), 6);
        assertEq(iter.next(), 0);
    }

    function testFuzzSingleMapNext(uint256[] memory arr) public {
        Iter memory iter = arr.toIter().map(__double);

        for (uint256 i; i < arr.length; i++) {
            uint256 element;
            unchecked { element = arr[i] * 2; }
            assertEq(iter.next(), element);
        }
        assertEq(iter.next(), 0);
    }

    function testDoubleMapNext() public {
        Iter memory iter = __defaultArr().toIter().map(__double).map(__triple);

        assertEq(iter.next(), 6);
        assertEq(iter.next(), 12);
        assertEq(iter.next(), 18);
        assertEq(iter.next(), 0);
    }

    function testFuzzDoubleMapNext(uint256[] memory arr) public {
        Iter memory iter = arr.toIter().map(__double).map(__triple);

        for (uint256 i; i < arr.length; i++) {
            uint256 element;
            unchecked { element = arr[i] * 6; }
            assertEq(iter.next(), element);
        }
        assertEq(iter.next(), 0);
    }

    function testSingleMapCollect() public {
        uint256[] memory arr = __defaultArr();
        Iter memory iter = arr.toIter().map(__double);

        uint256[] memory res = iter.collect();

        assertEq(res.length, arr.length);
        for (uint256 i; i < arr.length; i++) {
            uint256 element;
            unchecked { element = arr[i] * 2; }
            assertEq(res[i], element);
        }
    }

    function testFuzzSingleMapCollect(uint256[] memory arr) public {
        Iter memory iter = arr.toIter().map(__double);

        uint256[] memory res = iter.collect();

        assertEq(res.length, arr.length);
        for (uint256 i; i < arr.length; i++) {
            uint256 element;
            unchecked { element = arr[i] * 2; }
            assertEq(res[i], element);
        }
    }

    function testDoubleMapCollect() public {
        uint256[] memory arr = __defaultArr();
        Iter memory iter = arr.toIter().map(__double).map(__triple);

        uint256[] memory res = iter.collect();

        assertEq(res.length, arr.length);
        for (uint256 i; i < arr.length; i++) {
            uint256 element;
            unchecked { element = arr[i] * 6; }
            assertEq(res[i], element);
        }
    }

    function testFuzzDoubleMapCollect(uint256[] memory arr) public {
        Iter memory iter = arr.toIter().map(__double).map(__triple);

        uint256[] memory res = iter.collect();

        assertEq(res.length, arr.length);
        for (uint256 i; i < arr.length; i++) {
            uint256 element;
            unchecked { element = arr[i] * 6; }
            assertEq(res[i], element);
        }
    }

    // ---------------
    // -- utilities --
    // ---------------

    function __defaultArr() internal pure returns (uint256[] memory arr) {
        arr = new uint256[](3);
        arr[0] = 1;
        arr[1] = 2;
        arr[2] = 3;
    }

    function __double(uint256 x) internal pure returns (uint256) {
        unchecked { return x * 2; }
    }

    function __triple(uint256 x) internal pure returns (uint256) {
        unchecked { return x * 3; }
    }
}
