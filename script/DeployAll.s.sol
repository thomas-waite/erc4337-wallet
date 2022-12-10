// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.13;

import {SmartWallet} from "src/SmartWallet.sol";
import {PayMaster} from "src/PayMaster.sol";
import {EntryPoint} from "src/external/EntryPoint.sol";
import "forge-std/Script.sol";

// Deploy the smart wallet. Make use of a previously deployed ENTRY_POINT
// Note: The Paymaster is setup to pay for all transactions for all users, using ETH
contract DeployAll is Script {
    SmartWallet public wallet;
    PayMaster public paymaster;
    EntryPoint public entryPoint;

    address public constant OWNER = 0xB4c251bf29dEee4E74f128f8B8aAb5b61143F492;

    uint32 public constant UNSTAKE_DELAY = 100 seconds;
    uint112 PAYMASTER_DEPOSIT = 0.1 ether;
    uint112 PAYMASTER_STAKE = 0.1 ether;

    address constant CREATE2_FACTORY = 0xce0042B868300000d44A59004Da54A005ffdcf9f;
    uint256 MIN_PAYMASTER_STAKE_AMOUNT = 1e6;
    uint32 MIN_PAYMASTER_STAKE_DURATION = 1 seconds;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);
        entryPoint = new EntryPoint(CREATE2_FACTORY, MIN_PAYMASTER_STAKE_AMOUNT, MIN_PAYMASTER_STAKE_DURATION);
        wallet = new SmartWallet(address(entryPoint), OWNER);
        paymaster = new PayMaster(address(entryPoint));

        // 1. Stake ETH through paymaster on EntryPoint
        paymaster.addStake{value: PAYMASTER_STAKE}(UNSTAKE_DELAY);

        // 2. Deposit ETH to pay for user transactions
        paymaster.deposit{value: PAYMASTER_DEPOSIT}();

        // 3. Transfer some ETH to wallet
        payable(address(wallet)).transfer(0.1 ether);

        vm.stopBroadcast();
    }
}