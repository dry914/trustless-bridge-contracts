//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {TbToken} from "./TbToken.sol";


contract TbEth is TbToken {
	constructor() TbToken("Ether", "tbETH") {}
}