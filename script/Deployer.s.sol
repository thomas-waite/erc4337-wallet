// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.13;

import {SmartWallet} from "../src/SmartWallet.sol";
import "forge-std/Script.sol";

// Deploy the smart wallet. Make use of a previously deployed ENTRY_POINT
contract Deployer is Script {
    SmartWallet public wallet;

    address public constant ENTRY_POINT = 0x602aB3881Ff3Fa8dA60a8F44Cf633e91bA1FdB69;
    address public constant OWNER = 0x64c4Bffb220818F0f2ee6DAe7A2F17D92b359c5d;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);
        wallet = new SmartWallet(ENTRY_POINT, OWNER);
        vm.stopBroadcast();
    }
}
