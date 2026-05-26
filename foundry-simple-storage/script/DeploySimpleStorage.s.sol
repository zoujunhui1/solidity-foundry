//SPDX-License-Identifier: MIT
pragma solidity ^0.8.35;

import {Script} from "forge-std/Script.sol";
import {SimpleStorage} from "../src/SimpleStorage.sol";

contract DeploySimpleStorage is Script {
    function run() public returns (SimpleStorage) {
        // 返回合约实例，方便后续调用
        vm.startBroadcast();
        SimpleStorage simpleStorage = new SimpleStorage();
        vm.stopBroadcast();
        return simpleStorage;
    }
}
