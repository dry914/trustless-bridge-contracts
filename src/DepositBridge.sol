// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Deposit} from "./BridgeStruct.sol";


contract DepositBridge {
    uint256 lastDepositId;

    mapping(address => bool) tokenWhitelist;
    mapping(uint256 => Deposit) deposits;

    // TODO: add ownership
    function setTokenToWhitelist(address token) external /*onlyOwner*/ {
        tokenWhitelist[token] = true;
    }

    function deposit(address token, uint256 amount) external {
        deposits[++lastDepositId] = Deposit({
            token: token,
            receiver: msg.sender,
            amount: amount
        });
    }
}
