// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

struct Deposit {
    address token;
    address receiver;
    uint256 amount;
    uint256 chainId;
}
