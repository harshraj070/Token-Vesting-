//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;

import {Test} from "forge-std/Test.sol";
import {TokenVesting} from "../src/TokenVesting.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

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
        token = new MockERC20(); // Correct instantiation
        token.transfer(owner, 1000 ether);
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

    function testDeposit() public {
        uint256 depositAmount = 1000 ether;

        vm.prank(owner);
        token.approve(address(vesting), depositAmount);
        //vm.deal(owner, 10000 ether);
        vm.prank(owner);
        vesting.deposit(depositAmount);

        assertEq(vesting.getBalance(), depositAmount);
    }

    function testAfterCliff() public {
        uint256 depositAmount = 1000 ether;
        vm.prank(owner);
        token.approve(address(vesting), depositAmount);

        vm.prank(owner);
        vesting.deposit(depositAmount);

        vm.warp(startTime + vestingDuration + 1);
        uint256 releaseAmount = 500 ether;
        vm.prank(beneficiary);
        vesting.release(releaseAmount);

        assertEq(token.balanceOf(beneficiary), releaseAmount);
    }

    function testOnlyBeneficiarycanrelease() public {
        uint256 depositAmount = 1000 ether;
        vm.prank(owner);
        token.approve(address(vesting), depositAmount);

        vm.prank(owner);
        vesting.deposit(depositAmount);

        uint256 releaseAmount = 500 ether;
        vm.prank(owner);
        vm.expectRevert("Not beneficiary");
        vesting.release(releaseAmount);
    }

    function testVestedAmount() public {
        uint256 depositAmount = 1000 ether;

        vm.prank(owner);
        token.approve(address(vesting), depositAmount);
        vm.prank(owner);
        vesting.deposit(depositAmount);

        vm.warp(startTime + (vestingDuration / 2));

        uint256 expectedVested = (depositAmount * (vestingDuration / 2)) /
            vestingDuration;
        assertEq(vesting.vestedAmount(), expectedVested);
    }
}
