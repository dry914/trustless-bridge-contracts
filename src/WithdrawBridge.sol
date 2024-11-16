// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import { ITbToken } from "./tokens/interfaces/ITbToken.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { MPTProof } from "./MPTProof.sol";


contract WithdrawBridge {
    error WrongToken(address _underlyingToken);
    error WrongProof(bytes _root, bytes _result);
    error ClaimFailed();

    event Claimed(address indexed _receiver, uint256 indexed _amount);

    address constant NATIVE_TOKEN = address(0x123);
    address constant L1_SLOAD_ADDRESS = 0x0000000000000000000000000000000000000101;
    address internal l1Root;

    mapping(IERC20 => ITbToken) tokens;

    constructor(address _l1Root) {
        l1Root = _l1Root;
    }

    function setTokenToWhitelist(IERC20 _underlyingToken, ITbToken _tbToken) external /*onlyOwner*/ {
        tokens[_underlyingToken] = _tbToken;
    }

    function claimEth(
        address _receiver,
        uint256 _amount,
        uint256 _l1Slot,
        bytes calldata _proof,
        bytes32 _key,
        bytes32 _value
    ) external {
        _claim(NATIVE_TOKEN, _receiver, _amount, _l1Slot, _proof, _key, _value);
    }

    function claimErc20(
        address _underlyingToken,
        address _receiver,
        uint256 _amount,
        uint256 _l1Slot,
        bytes calldata _proof,
        bytes32 _key,
        bytes32 _value
    ) external {
        _claim(_underlyingToken, _receiver, _amount, _l1Slot, _proof, _key, _value);
    }

    function _claim(
        address _underlyingToken,
        address _receiver,
        uint256 _amount,
        uint256 _l1Slot,
        bytes calldata _proof,
        bytes32 _key,
        bytes32 _value
    ) internal {
        bytes memory _root = readSingleSlot(l1Root, _l1Slot);

        bytes memory res = MPTProof.verifyRLPProof(_proof, abi.decode(_root, (bytes32)), _key);
        if (bytes32(res) != _value) {
            revert WrongProof(_root, res);
        }

        ITbToken _tbToken = tokens[IERC20(_underlyingToken)];

        if (_tbToken == ITbToken(address(0))) {
            revert WrongToken(_underlyingToken);
        }

        if (_underlyingToken == NATIVE_TOKEN) {
            (bool success, ) = payable(_receiver).call{value: _amount}("");
            if (!success) {
                revert ClaimFailed();
            }
        } else {
            _tbToken.mint(_receiver, _amount);
        }
        // TODO: check value validity(value=hash(token,receiver,amount,chainId))
        emit Claimed(_receiver, _amount);
    }

    function readSingleSlot(address l1_contract, uint256 slot) public view returns (bytes memory) {

        bytes memory input = abi.encodePacked(l1_contract, slot);

        bool success;
        bytes memory result;

        (success, result) = L1_SLOAD_ADDRESS.staticcall(input);

        if (!success) {
            revert("L1SLOAD failed");
        }

        return result;

    }

    receive() external payable {
    }
}
