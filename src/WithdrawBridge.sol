// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {ITbToken} from "./tokens/interfaces/ITbToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract WithdrawBridge {
    error WrongToken(address _underlyingToken);

    event Claimed(address indexed _receiver, uint256 indexed _amount);

    address constant NATIVE_TOKEN = address(0x123);

    mapping(IERC20 => ITbToken) tokens;

    constructor() {
    }

    function setTokenToWhitelist(IERC20 _underlyingToken, ITbToken _tbToken) external /*onlyOwner*/ {
        tokens[_underlyingToken] = _tbToken;
    }

    function claimEth(
        address _receiver,
        uint256 _amount,
        uint256 _chainId,
        bytes calldata _proof,
        bytes32 _key,
        bytes32 _value
    ) external {
        // TODO: get root from L1SLOAD
        // TODO: check proof in root
        // TODO: ENS instead _receiver address

        _claim(NATIVE_TOKEN, _receiver, _amount);
    }

    function claimErc20(
        address _underlyingToken,
        address _receiver,
        uint256 _amount,
        uint256 _chainId,
        bytes calldata _proof,
        bytes32 _key,
        bytes32 _value
    ) external {
        // TODO: get root from L1SLOAD
        // TODO: check proof in root
        // TODO: ENS instead _receiver address

        _claim(_underlyingToken, _receiver, _amount);
    }

    function _claim(
        address _underlyingToken,
        address _receiver,
        uint256 _amount
    ) internal {
        ITbToken _tbToken = tokens[IERC20(_underlyingToken)];

        if (_tbToken == ITbToken(address(0))) {
            revert WrongToken(_underlyingToken);
        }

        _tbToken.mint(_receiver, _amount);
        emit Claimed(_receiver, _amount);
    }
}