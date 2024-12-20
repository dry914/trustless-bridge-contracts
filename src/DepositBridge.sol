// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import { IEntropyConsumer } from "@pythnetwork/entropy-sdk-solidity/IEntropyConsumer.sol";
import { IEntropy } from "@pythnetwork/entropy-sdk-solidity/IEntropy.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Deposit } from "./BridgeStruct.sol";


contract DepositBridge is IEntropyConsumer {
    error WrongToken(address _underlyingToken);
    error ZeroAmount();
    error WrongDepositId(uint256 _depositId);
    error WrongReceiver(address _receiver);
    error CallbackFailed();

    event Deposited(
        uint256 indexed depositId,
        uint256 indexed fee
    );
    event Withdrawn(
        address token,
        address receiver,
        uint256 amount,
        uint256 chainId
    );
    event WhitelistChanged(
        IERC20 token,
        bool added
    );
    event WinOrLoss(bool win);

    address constant NATIVE_TOKEN = address(0x123);
    uint256 lastDepositId;
    uint256 chainId;

    mapping(IERC20 => bool) tokenWhitelist;
    mapping(uint256 => Deposit) deposits;
    mapping(uint256 => bytes32) depositHashes;
    mapping(uint64 => uint256) depositCallbacks;

    uint256 constant FEE = 10e6;
    uint256 constant FEE_DIV = 10e8;
    IEntropy public entropy;

    constructor(address entropyAddress) {
        entropy = IEntropy(entropyAddress);
    }

    // TODO: add ownership
    function setTokenToWhitelist(IERC20 _token, bool _added) external /** onlyOwner */ {
        tokenWhitelist[_token] = _added;
        emit WhitelistChanged(_token, _added);
    }

    function depositEth(
        address _receiver,
        uint256 _chainId,
        bytes32 _userRandomNumber
    ) payable external returns(uint256) {
        return _deposit(NATIVE_TOKEN, msg.value, _receiver, _chainId, _userRandomNumber);
    }

    function depositErc20(
        IERC20 _token,
        uint256 _amount,
        address _receiver,
        uint256 _chainId,
        bytes32 _userRandomNumber
    ) external returns(uint256) {
        if (!tokenWhitelist[_token] || address(_token) == NATIVE_TOKEN) {
            revert WrongToken(address(_token));
        }
        _token.transferFrom(_receiver, address(this), _amount);

        return _deposit(address(_token), _amount, _receiver, _chainId, _userRandomNumber);
    }

    function _deposit(
        address _token,
        uint256 _amount,
        address _receiver,
        uint256 _chainId,
        bytes32 _userRandomNumber
    ) internal returns(uint256) {
        if (_amount == 0) {
            revert ZeroAmount();
        }

        uint256 _lastDepositId = ++lastDepositId;

        uint64 _sequenceNumber;
        uint256 _entropyFee;
        (_sequenceNumber, _entropyFee) = _requestRandomNumber(_userRandomNumber);
        depositCallbacks[_sequenceNumber] = _lastDepositId;

        uint256 _protocolFee = _amount * FEE / FEE_DIV;
        uint256 _fee = _entropyFee + _protocolFee;

        Deposit memory _deposit = Deposit({
            token: _token,
            receiver: _receiver,
            amount: _amount - _fee,
            chainId: _chainId,
            fee: _protocolFee,
            sender: msg.sender
        });
        deposits[_lastDepositId] = _deposit;

        depositHashes[_lastDepositId] = keccak256(abi.encode(
            _deposit.token,
            _deposit.receiver,
            _deposit.amount,
            _deposit.chainId
        ));
        emit Deposited(_lastDepositId, _fee);
        return _lastDepositId;
    }

    // @param userRandomNumber The random number generated by the user.
    function _requestRandomNumber(bytes32 _userRandomNumber) internal returns(uint64 _sequenceNumber, uint256 _entropyFee) {
        // Get the default provider and the fee for the request
        address _entropyProvider = entropy.getDefaultProvider();
        uint256 _entropyFee = entropy.getFee(_entropyProvider);

        // Request the random number with the callback
        _sequenceNumber = entropy.requestWithCallback{ value: _entropyFee }(
            _entropyProvider,
            _userRandomNumber
        );
        // Store the sequence number to identify the callback request
    }

    function entropyCallback(
        uint64 sequenceNumber,
        address provider,
        bytes32 randomNumber
    ) internal override {
        uint256 _depositId = depositCallbacks[sequenceNumber];
        Deposit memory _deposit = deposits[_depositId];

        bool win = (uint256(randomNumber) % 2 == 0);
        if (win) {
            (bool success, ) = payable(_deposit.sender).call{value: _deposit.fee}("");
            if (!success) {
                revert CallbackFailed();
            }
        }
        emit WinOrLoss(win);
    }

    // TODO: refactor
    function emergancyWithdraw(uint256 _depositId) external /** onlyOwner */ {
        Deposit memory _deposit = deposits[_depositId];
        if (_deposit.receiver != msg.sender) {
            revert WrongReceiver(_deposit.receiver);
        }

        delete deposits[_depositId];
        delete depositHashes[_depositId];

        (bool success, ) = msg.sender.call{value: _deposit.amount}("");
        emit Withdrawn(_deposit.token, _deposit.receiver, _deposit.amount, _deposit.chainId);
        require(success, "ETH transfer failed");
    }

    function getDeposit(uint256 _depositId) external view returns(Deposit memory _deposit) {
        Deposit memory _deposit = deposits[_depositId];
        if (_deposit.amount == 0) {
            revert WrongDepositId(_depositId);
        }
    }

    function getDepositHash(uint256 _depositId) external view returns(bytes32 _depositHash) {
        _depositHash = depositHashes[_depositId];
        if (_depositHash == 0) {
            revert WrongDepositId(_depositId);
        }
    }

    // This method is required by the IEntropyConsumer interface.
    // It returns the address of the entropy contract which will call the callback.
    function getEntropy() internal view override returns (address) {
        return address(entropy);
    }
}
