// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TokenVesting is Ownable {
    IERC20 public token;
    address public _beneficiary;
    uint256 public _startTime;
    uint256 public _cliffDuration;
    uint256 public _vestingDuration;

    mapping(address => uint256) private _balances;

    constructor(
        address tokenAddress,
        address beneficiary,
        uint256 startTime,
        uint256 cliffDuration,
        uint256 vestingDuration
    ) Ownable(msg.sender) {
        token = IERC20(tokenAddress); // Initialize the token contract
        _beneficiary = beneficiary;
        _startTime = startTime;
        _cliffDuration = cliffDuration;
        _vestingDuration = vestingDuration;
    }

    // Get contract token balance
    function getBalance() public view returns (uint256) {
        return token.balanceOf(address(this));
    }

    // Deposit tokens into vesting contract
    function deposit(uint256 amount) external onlyOwner {
        token.transferFrom(msg.sender, address(this), amount);
    }

    // Release vested tokens to beneficiary
    function release(uint256 amount) external {
        require(msg.sender == _beneficiary, "Not beneficiary");
        require(
            amount <= token.balanceOf(address(this)),
            "Amount exceeds vested tokens"
        );
        require(
            block.timestamp >= _startTime + _vestingDuration,
            "Cliff not reached"
        );

        token.transfer(_beneficiary, amount);
    }

    function vestedAmount() external returns (uint256) {
        uint256 multiplicant = block.timestamp - _startTime;
        uint256 vested = (token.balanceOf(address(this)) * multiplicant) /
            _vestingDuration;
        return vested;
    }

    function approveTokens(uint256 amount) external {
        token.approve(address(this), amount);
    }
}
