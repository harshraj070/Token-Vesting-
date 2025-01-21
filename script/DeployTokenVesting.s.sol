// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "src/TokenVesting.sol";

contract DeployTokenVesting is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address tokenAddress = vm.envAddress("TOKEN_ADDRESS");
        address beneficiary = vm.envAddress("BENEFICIARY");
        uint256 startTime = vm.envUint("START_TIME");
        uint256 cliffDuration = vm.envUint("CLIFF_DURATION");
        uint256 vestingDuration = vm.envUint("VESTING_DURATION");

        vm.startBroadcast(deployerPrivateKey);
        TokenVesting vesting = new TokenVesting(
            tokenAddress,
            beneficiary,
            startTime,
            cliffDuration,
            vestingDuration
        );
        vm.stopBroadcast();
    }
}
