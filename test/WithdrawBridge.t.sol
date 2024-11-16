// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { Test } from "forge-std/Test.sol";
import { StdCheats } from "forge-std/StdCheats.sol";

import { TbToken } from "../src/tokens/TbToken.sol";
import { TbEth } from "../src/tokens/TbEth.sol";
import { WithdrawBridge } from "src/WithdrawBridge.sol";


contract UnderlyingUsdt is ERC20 {

	constructor(string memory _name, string memory _symbol)
		ERC20(_name, _symbol) {
	}

	function mint(address dest, uint256 amount) public {
		_mint(dest, amount);
	}

}


contract WithdrawBridgeTest is StdCheats, Test {
    address constant NATIVE_TOKEN = address(0x123);
    uint256 constant CHAIN_ID = 111;

    UnderlyingUsdt underlyingUsdt;
    TbEth tbEth;

    address owner;
    WithdrawBridge withdrawBridge;

    function setUp() public {
        owner = msg.sender;
        tbEth = new TbEth();
        withdrawBridge = new WithdrawBridge();
    }

    function testSetTokenToWhitelist() public {
        // wrong deposit id
        vm.expectRevert(
            abi.encodeWithSelector(WithdrawBridge.WrongToken.selector, NATIVE_TOKEN)
        );
        withdrawBridge.claimEth(
            owner,
            10 ether,
            CHAIN_ID,
            abi.encodePacked("foundry test"),
            keccak256("asd"),
            keccak256("qwe")
        );

        withdrawBridge.setTokenToWhitelist(IERC20(NATIVE_TOKEN), tbEth);

        withdrawBridge.claimEth(
            owner,
            10 ether,
            CHAIN_ID,
            abi.encodePacked("foundry test"),
            keccak256("asd"),
            keccak256("qwe")
        );
    }

    function testWithdrawEth() public {
        tbEth.mint(address(withdrawBridge), 100 ether);
        withdrawBridge.setTokenToWhitelist(IERC20(NATIVE_TOKEN), tbEth);

        assertEq(tbEth.balanceOf(address(withdrawBridge)), 100 ether);
        assertEq(tbEth.balanceOf(owner), 0 ether);

        withdrawBridge.claimEth(
            owner,
            10 ether,
            CHAIN_ID,
             abi.encodePacked("foundry test"),
            keccak256("asd"),
            keccak256("qwe")
        );

        assertEq(tbEth.balanceOf(address(withdrawBridge)), 100 ether);
        assertEq(tbEth.balanceOf(owner), 10 ether);
    }
}