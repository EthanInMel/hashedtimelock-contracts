// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {HashedTimelockETH} from "../src/HashedTimelockETH.sol";

contract HashedTimelockETHTest is Test {
    HashedTimelockETH public hashedTimelock;

    address Alice = 0xF248F846c9C667b27a07E949c30C7e61820B8886;
    address Bob = 0xD78fD2cDf9b6d9F810b23cEb52C84d9d74C3A868;

    function setUp() public {
        hashedTimelock = new HashedTimelockETH();
        vm.deal(Alice, 1 ether);
    }

    function test_InitiateLock() public returns (bytes32) {
        vm.prank(Alice);
        bytes32 secret = "secret";
        bytes32 hashedSecret = keccak256(abi.encodePacked(secret));
        uint256 lockTime = block.timestamp + 6000;
        hashedTimelock.initiateLock{value: 1000 wei}(hashedSecret, Bob, lockTime);
        bytes32 lockId = keccak256(abi.encodePacked(Alice, Bob, uint256(1000 wei), lockTime, hashedSecret));
        console2.logBytes32(lockId);
        return lockId;
    }

    function test_Claim() public {
        bytes32 lockId = test_InitiateLock();
        vm.prank(Bob);
        bytes32 secret = "secret";
        hashedTimelock.claim(lockId, secret);
    }
}
