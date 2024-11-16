// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;


contract WithdrawBridge {

    function claim(address token, address receiver, uint256 amount, bytes32 proof, uint256 blockNumber) external {
        // TODO: get root from L1SLOAD
        // TODO: check proof in root
        // TODO: mint wToken
    }
}
