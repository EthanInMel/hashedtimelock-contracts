// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./interfaces/IHashedTimelockETH.sol";

contract HashedTimelockETH is IHashedTimelockETH {
    struct Lock {
        bytes32 hashedSecret;
        State state;
        address sender;
        address recipient;
        uint256 lockTime;
        uint256 amount;
    }

    mapping(bytes32 => Lock) idTolocks;

    //For client usage
    Lock[] locks;

    function getLocks() external view returns (Lock[] memory) {
        return locks;
    }

    function initiateLock(bytes32 hashedSecret, address recipient, uint256 lockTime) external payable {
        bytes32 lockId = keccak256(abi.encodePacked(msg.sender, recipient, msg.value, lockTime, hashedSecret));
        require(idTolocks[lockId].state == State.INITIATED, "Lock already exists");
        Lock memory newLock = Lock(hashedSecret, State.LOCKED, msg.sender, recipient, lockTime, msg.value);
        idTolocks[lockId] = newLock;
        locks.push(newLock);
        emit LockInitiated(lockId, msg.sender, recipient, msg.value, lockTime, hashedSecret);
    }

    function claim(bytes32 lockId, bytes32 secret) external {
        Lock memory lock = idTolocks[lockId];
        require(lock.state != State.INITIATED, "Lock does not exist");
        require(lock.state != State.UNLOCKED, "Already claimed");
        require(lock.lockTime > block.timestamp, "Expired");
        require(lock.hashedSecret == keccak256(abi.encodePacked(secret)), "Wrong secret");
        require(lock.recipient == msg.sender, "Wrong recipient");
        payable(lock.recipient).transfer(lock.amount);
        idTolocks[lockId].state = State.UNLOCKED;
        //Todo: update locks as well, but it is not neccessary since we will use indexer to get locks
        emit LockClaimed(lockId);
    }

    function refund(bytes32 lockId) external {
        Lock memory lock = idTolocks[lockId];
        require(lock.state == State.LOCKED, "Lock does not exist");
        require(lock.sender == msg.sender, "Not sender");
        require(lock.state == State.LOCKED, "Not refundable");
        require(lock.lockTime <= block.timestamp, "Time locked");
        payable(lock.sender).transfer(lock.amount);
        idTolocks[lockId].state = State.REFUNDED;
        //Todo: update locks as well
        emit LockRefunded(lockId);
    }
}
