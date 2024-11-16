//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {TbToken} from "./TbToken.sol";


contract TbUsdt is TbToken {
	constructor(string memory _name, string memory _symbol)
		TbToken(_name, _symbol) {
	}
}