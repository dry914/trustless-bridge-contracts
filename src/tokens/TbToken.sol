//SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ITbToken} from "./interfaces/ITbToken.sol";

// trust bridge token
contract TbToken is ITbToken, ERC20 {

	constructor(string memory _name, string memory _symbol)
		ERC20(_name, _symbol) {
	}

	function mint(address dest, uint256 amount) public {
		_mint(dest, amount);
	}

}
