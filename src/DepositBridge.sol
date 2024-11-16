// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Deposit} from "./BridgeStruct.sol";


contract DepositBridge {
    error WrongToken(address _underlyingToken);
    error ZeroAmount();
    error WrongDepositId(uint256 _depositId);

    address constant NATIVE_TOKEN = address(0x123);
    uint256 lastDepositId;
    uint256 chainId;

    mapping(IERC20 => bool) tokenWhitelist;
    mapping(uint256 => Deposit) deposits;
    mapping(uint256 => bytes32) depositHashes;

    constructor() {
    }

    // TODO: add ownership
    function setTokenToWhitelist(IERC20 _token) external /*onlyOwner*/ {
        tokenWhitelist[_token] = true;
    }

    function depositEth(
        address _receiver,
        uint256 _chainId
    ) payable external returns(uint256) {
        return _deposit(NATIVE_TOKEN, msg.value, _receiver, _chainId);
    }

    function depositErc20(
        IERC20 _token,
        uint256 _amount,
        address _receiver,
        uint256 _chainId
    ) external returns(uint256) {
        if (!tokenWhitelist[_token] || address(_token) == NATIVE_TOKEN) {
            revert WrongToken(address(_token));
        }
        _token.transferFrom(_receiver, address(this), _amount);

        return _deposit(address(_token), _amount, _receiver, _chainId);
    }

    function _deposit(
        address _token,
        uint256 _amount,
        address _receiver,
        uint256 _chainId
    ) internal returns(uint256) {
        if (_amount == 0) {
            revert ZeroAmount();
        }
        Deposit memory _deposit = Deposit({
            token: _token,
            receiver: _receiver,
            amount: _amount,
            chainId: _chainId
        });

        uint256 _lastDepositId = ++lastDepositId;
        deposits[_lastDepositId] = _deposit;
        depositHashes[_lastDepositId] = keccak256(abi.encode(
            _deposit.token,
            _deposit.receiver,
            _deposit.amount,
            _deposit.chainId
        ));

        return _lastDepositId;
    }

    function getDeposit(uint256 _depositId) external view returns(Deposit memory) {
        Deposit memory _deposit = deposits[_depositId];
        if (_deposit.amount == 0) {
            revert WrongDepositId(_depositId);
        }
        return deposits[_depositId];
    }
}
