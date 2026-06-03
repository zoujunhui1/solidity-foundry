//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Script,console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract CreateSubscription is Script {
    function CreateSubscriptionUsingConfig() public returns(uint256) {
        HelperConfig helperConfig = new HelperConfig();
        (, , address vrfCoordinatorV2, , , , ,) = helperConfig.activeNetworkConfig();
        return createSubscription(vrfCoordinatorV2);
    }

    function createSubscription( address vrfCoordinatorV2)  public returns(uint256) {
        vm.startBroadcast();
        VRFCoordinatorV2_5Mock vrfCoordinator = VRFCoordinatorV2_5Mock(vrfCoordinatorV2);
        uint256 subId = vrfCoordinator.createSubscription();
        vm.stopBroadcast();
        return subId;
    }

    function run() external returns(uint256 ) {
        return CreateSubscriptionUsingConfig();
    }
}

contract FundSubscription is Script {
    uint96 public constant FUND_AMOUNT = 3 ether;

    function fundSubscriptionUsingConfig() public {
        HelperConfig helperConfig = new HelperConfig();
        (, , address vrfCoordinatorV2, , uint256 subscriptionId, , , address link) = helperConfig.activeNetworkConfig();
        fundSubscription(vrfCoordinatorV2, subscriptionId, link, FUND_AMOUNT);
    }

    function fundSubscription(
        address vrfCoordinatorV2,
        uint256 subscriptionId,
        address link,
        uint96 fundAmount
    ) public {
       if (block.chainid == 31337){
            vm.startBroadcast();
            VRFCoordinatorV2_5Mock vrfCoordinator = VRFCoordinatorV2_5Mock(vrfCoordinatorV2);
            vrfCoordinator.fundSubscription(subscriptionId, fundAmount);
            vm.stopBroadcast();
       }else{
            vm.startBroadcast();
            LinkToken(link).transferAndCall(
                vrfCoordinatorV2,
                FUND_AMOUNT,
                abi.encode(subscriptionId)
            );
            vm.stopBroadcast();
       }
    }

    function run() external {
        fundSubscriptionUsingConfig();
    }
}
    
contract AddConsumer is Script {
    function addConsumer(address vrfCoordinatorV2, uint256 subscriptionId, address raffle) public {
        vm.startBroadcast();
        VRFCoordinatorV2_5Mock vrfCoordinator = VRFCoordinatorV2_5Mock(vrfCoordinatorV2);
        vrfCoordinator.addConsumer(subscriptionId, raffle);
        vm.stopBroadcast();
    }
    
    function addConsumerUsingConfig(address raffle) public {
        HelperConfig helperConfig = new HelperConfig();
        (, , address vrfCoordinatorV2, , uint256 subscriptionId, , , ) = helperConfig.activeNetworkConfig();
        addConsumer(vrfCoordinatorV2, subscriptionId, raffle);
    }

    function run()  external {
        address raffle = DevOpsTools.get_most_recent_deployment(
            "Raffle",
            block.chainid
        );
        addConsumerUsingConfig(raffle);
    }
}