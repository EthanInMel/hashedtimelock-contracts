// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract IHashedTimelockETH {
    enum State {
        INITIATED,
        LOCKED,
        UNLOCKED,
        REFUNDED
    }

    event LockInitiated(
        bytes32 indexed lockId,
        address indexed sender,
        address indexed recipient,
        uint256 amount,
        uint256 lockTime,
        bytes32 hashedSecret
    );

    event LockClaimed(bytes32 indexed lockId);

    event LockRefunded(bytes32 indexed lockId);
}
