//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {TbToken} from "./TbToken.sol";


contract TbUsdt is TbToken {
	constructor() TbToken("Tether", "tbUSDT") {}
}