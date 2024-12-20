// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { Test } from "forge-std/Test.sol";
import { StdCheats } from "forge-std/StdCheats.sol";

import { TbUsdt } from "../src/tokens/TbUsdt.sol";
import { DepositBridge } from "../src/DepositBridge.sol";


contract UnderlyingUsdt is ERC20{

	constructor(string memory _name, string memory _symbol)
		ERC20(_name, _symbol) {
	}

	function mint(address dest, uint256 amount) public {
		_mint(dest, amount);
	}

}


contract TokenERC20Test is StdCheats, Test {
    address constant NATIVE_TOKEN = address(0x123);
    uint256 constant CHAIN_ID = 2227728;
    address constant OPTIMISM_SEPOLIA_ENTROPY = address(0x4821932D0CDd71225A6d914706A621e0389D7061);

    UnderlyingUsdt underlyingUsdt;
    TbUsdt tbUsdt;

    address owner;
    DepositBridge depositBridge;

    function setUp() public {
        owner = msg.sender;

        // TODO: fix decimals for USDT to 6
        underlyingUsdt = new UnderlyingUsdt("Tether", "USDT");
        tbUsdt = new TbUsdt();

        depositBridge = new DepositBridge(OPTIMISM_SEPOLIA_ENTROPY);
    }

    function testInvariantMetadata() public {
        assertEq(tbUsdt.name(), "Tether");
        assertEq(tbUsdt.symbol(), "tbUSDT");
        assertEq(tbUsdt.decimals(), 18);
    }

    function testMint() public {
        tbUsdt.mint(address(0xBEEF), 1e18);

        assertEq(tbUsdt.totalSupply(), 1e18);
        assertEq(tbUsdt.balanceOf(address(0xBEEF)), 1e18);
    }

    // function testDepositErc20() public {
    //     vm.prank(owner);
    //     underlyingUsdt.mint(owner, 1000 * 10e18);

    //     uint256 _amount = 10**18;
    //     depositBridge.depositErc20(IERC20(underlyingUsdt), _amount, owner, 123);
    // }

    // function testDepositEth() public {
    //     hoax(owner, 100 ether);
    //     depositBridge.depositEth{value: 0.2 ether}(owner, CHAIN_ID, hex"1234567890");

    //     // check balances after deposit
    //     assertEq(owner.balance, 99.8 ether);
    //     assertEq(depositBridge.getDeposit(1).receiver, owner);
    //     assertEq(depositBridge.getDeposit(1).amount, 0.2 ether);
    //     assertEq(depositBridge.getDeposit(1).token, NATIVE_TOKEN);
    //     assertEq(depositBridge.getDeposit(1).chainId, CHAIN_ID);

    //     // wrong deposit id
    //     vm.expectRevert(
    //         abi.encodeWithSelector(DepositBridge.WrongDepositId.selector, 112233)
    //     );
    //     depositBridge.getDeposit(112233);
    // }
}