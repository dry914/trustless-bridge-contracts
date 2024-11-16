// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {ITbToken} from "./tokens/interfaces/ITbToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract WithdrawBridge {
    error WrongToken(address _underlyingToken);

    mapping(IERC20 => ITbToken) tokens;

    constructor() {
    }

    function setTokenToWhitelist(IERC20 _underlyingToken, ITbToken _tbToken) external /*onlyOwner*/ {
        tokens[_underlyingToken] = _tbToken;
    }

    function claim(
        address _underlyingToken,
        address _receiver,
        uint256 _amount,
        uint256 _chainId,
        bytes32 _proof,
        uint256 _blockNumber
    ) external {
        // TODO: get root from L1SLOAD
        // TODO: check proof in root

        ITbToken _tbToken = tokens[IERC20(_underlyingToken)];
        if (_tbToken == ITbToken(address(0))) {
            revert WrongToken(_underlyingToken);
        }

        // TODO: ENS instead _receiver address
        _tbToken.mint(_receiver, _amount);
    }
}
