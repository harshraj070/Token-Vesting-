//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {TokenVesting} from "../src/TokenVesting.sol";
import "openzeppelin-contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor() ERC20("MockToken", "MTK") {
        _mint(msg.sender, 1_000_000 ether);
    }
}
contract TestTokenVesting is Test {
    TokenVesting public vesting;
    MockERC20 public token;
    address public owner = address(1);
    address public beneficiary = address(2);
    uint256 public startTime;
    uint256 public cliffDuration = 30 days;
    uint256 public vestingDuration = 180 days;
    function setUp() public {
        token = new MockERC20;
        startTime = block.timestamp;
        vm.prank(owner);
        vesting = new TokenVesting(
            address(token),
            beneficiary,
            startTime,
            cliffDuration,
            vestingDuration
        );
    }

    function testDeposit() {
        vm.deal(owner, 100 ether);
        uint256 depositAmount = 50 ether;
        token.approve(address(vesting), depositAmount);
        vesting.deposit(depositAmount);
        assertEq(vesting.getBalance(), depositAmount);
    }
}
