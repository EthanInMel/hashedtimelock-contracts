// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IHashedTimelockETH.sol";
import {Test, console2} from "forge-std/Test.sol";

contract HashedTimelockETH is IHashedTimelockETH {
    struct Lock {
        bytes32 hashedSecret;
        address sender;
        address recipient;
        uint256 lockTime;
        uint256 amount;
        State state;
    }

    mapping(bytes32 => Lock) locks;

    modifier onlyUnlocked(bytes32 lockId) {
        _onlyUnlocked(lockId);
        _;
    }

    //gas saving
    function _onlyUnlocked(bytes32 lockId) private view {
        require(
            locks[lockId].state == State.UNLOCKED,
            "Lock is not in the UNLOCKED state"
        );
    }

    function initiateLock(
        bytes32 hashedSecret,
        address recipient,
        uint256 lockTime
    ) external payable {
        bytes32 lockId = keccak256(
            abi.encodePacked(
                msg.sender,
                recipient,
                msg.value,
                lockTime,
                hashedSecret
            )
        );
        console2.logBytes32(lockId);

        require(locks[lockId].state == State.INITIATED, "Lock already exists");

        Lock memory newLock = Lock(
            hashedSecret,
            msg.sender,
            recipient,
            lockTime,
            msg.value,
            State.LOCKED
        );
        locks[lockId] = newLock;
        emit LockInitiated(
            lockId,
            msg.sender,
            recipient,
            msg.value,
            lockTime,
            hashedSecret
        );
    }

    function claim(bytes32 lockId, bytes32 secret) external {
        require(locks[lockId].state == State.LOCKED, "Lock does not exist");
        Lock storage lock = locks[lockId];
        require(
            locks[lockId].hashedSecret == keccak256(abi.encodePacked(secret)),
            "Wrong secret"
        );
        require(locks[lockId].recipient == msg.sender, "Wrong recipient");
        require(locks[lockId].state == State.LOCKED, "Already claimed");
        require(locks[lockId].lockTime > block.timestamp, "Expired");
        payable(lock.recipient).transfer(lock.amount);
        lock.state = State.UNLOCKED;
        emit LockClaimed(lockId);
    }

    function refund(bytes32 lockId) external {
        require(locks[lockId].state == State.LOCKED, "Lock does not exist");
        require(locks[lockId].sender == msg.sender, "Not sender");
        require(locks[lockId].state == State.LOCKED, "Not refundable");
        require(locks[lockId].lockTime <= block.timestamp, "Time locked");
        Lock storage lock = locks[lockId];
        payable(lock.sender).transfer(lock.amount);
        lock.state = State.REFUNDED;
        emit LockRefunded(lockId);
    }
}
