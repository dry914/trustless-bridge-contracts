// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./MPTProofHelper.sol";

contract MPTProofTest is Test {
    using stdJson for string;

    struct ProofData {
        bytes proof;
        bytes32 root;
        bytes32 key;
        bytes value;
    }

    MPTProofHelper verifier;

    function setUp() public {
        verifier = new MPTProofHelper();
    }

    function testERC20VerifyMembership() public {
        string[] memory inputs = readDataList(1000);
        for (uint256 i = 0; i < 1; i++) {
            ProofData memory data = readData(string(abi.encodePacked("./test/data/", inputs[i])));
            // it means a existence proof
            if (data.value.length > 0) {
                bytes memory res = verifier.verifyRLPProof(data.proof, data.root, data.key);
                assertEq(data.value, res);
            }
        }
    }

    // Utility functions

    function readData(string memory path) internal returns (ProofData memory) {
        ProofData memory data;
        string memory json = vm.readFile(path);

        data.proof = decodeHexString(json.readString(".proof"));
        data.root = decodeHexStringToBytes32(json.readString(".root"));
        data.key = decodeHexStringToBytes32(json.readString(".key"));
        data.value = decodeHexString(json.readString(".value"));

        return data;
    }

    function readDataList(uint256 num) internal pure returns (string[] memory lst) {
        assert(num <= 1000);
        lst = new string[](num);
        for (uint256 i = 0; i < num; i++) {
            string memory n = Strings.toString(i);
            if (i < 10) {
                lst[i] = string(abi.encodePacked("00", n, ".json"));
            } else if (i < 100) {
                lst[i] = string(abi.encodePacked("0", n, ".json"));
            } else {
                lst[i] = string(abi.encodePacked(n, ".json"));
            }
        }
        return lst;
    }

    function decodeHexChar(uint8 c) internal pure returns (uint8) {
        if (bytes1(c) >= bytes1("0") && bytes1(c) <= bytes1("9")) {
            return c - uint8(bytes1("0"));
        } else if (bytes1(c) >= bytes1("a") && bytes1(c) <= bytes1("f")) {
            return 10 + c - uint8(bytes1("a"));
        }
        revert("unsupported char found");
    }

    function decodeHexString(string memory s) internal pure returns (bytes memory) {
        bytes memory ss = bytes(s);
        require(ss.length % 2 == 0); // length must be even
        bytes memory r = new bytes(ss.length/2);
        for (uint256 i = 0; i < ss.length / 2; ++i) {
            r[i] = bytes1(decodeHexChar(uint8(ss[2 * i])) * 16 + decodeHexChar(uint8(ss[2 * i + 1])));
        }
        return r;
    }

    function decodeHexStringToBytes32(string memory s) internal pure returns (bytes32) {
        bytes memory bz = decodeHexString(s);
        require(bz.length == 32);
        return bytes32(bz);
    }
}
