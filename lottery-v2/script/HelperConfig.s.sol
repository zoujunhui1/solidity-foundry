// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        uint256 entranceFee;
        uint256 interval;
        address vrfCoordinatorV2;
        bytes32 gasLane;
        uint256 subscriptionId;
        uint32 callbackGasLimit;
        bool enableNativePayment;
        address link;
    }
    NetworkConfig public activeNetworkConfig;
    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepSepConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepSepConfig() public pure returns(NetworkConfig memory) {
        return NetworkConfig({
            entranceFee: 0.01 ether,
            interval: 30,
            vrfCoordinatorV2: 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B,
            gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            subscriptionId: 60013827626181162703804850792189948084800177795909263168078344638413941561490,
            callbackGasLimit: 500000,
            enableNativePayment: false,
            link: 0x779877A7B0D9E8603169DdbD7836e478b4624789
        });
    }

    function getOrCreateAnvilEthConfig() public returns(NetworkConfig memory) {
        if (activeNetworkConfig.vrfCoordinatorV2 != address(0)) {
            return activeNetworkConfig;
        }
        uint96 baseFee = 0.25 ether;
        uint96 gasPriceLink = 1e9;
        int256 weiPerUnitLink = 4e15;

        vm.startBroadcast();
        VRFCoordinatorV2_5Mock vrfCoordinatorV2 = new VRFCoordinatorV2_5Mock(
            baseFee,
            gasPriceLink,
            weiPerUnitLink
        );
        LinkToken linkToken = new LinkToken();
        uint256 subscriptionId = vrfCoordinatorV2.createSubscription();
        vm.stopBroadcast();

        return NetworkConfig({
            entranceFee: 0.01 ether,
            interval: 30,
            vrfCoordinatorV2: address(vrfCoordinatorV2),
            gasLane: 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae,
            subscriptionId: subscriptionId,
            callbackGasLimit: 500000,
            enableNativePayment: false,
            link: address(linkToken)
        });
    }
}
