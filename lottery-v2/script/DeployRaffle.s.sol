// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {Raffle} from "../src/Raffle.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {CreateSubscription,FundSubscription, AddConsumer} from "./Interaction.s.sol";

contract DeployRaffle is Script {
    uint96 public constant FUND_AMOUNT = 3 ether;
    
    function run() public returns(Raffle,HelperConfig ) {
        HelperConfig helperConfig = new HelperConfig();
        (uint256 entranceFee, uint256 interval, address vrfCoordinatorV2, 
        bytes32 gasLane, uint256 subscriptionId, uint32 callbackGasLimit,
         bool enableNativePayment, address link) = helperConfig.activeNetworkConfig();
         vm.startBroadcast();

         Raffle raffle = new Raffle(
            entranceFee,
            interval,
            vrfCoordinatorV2,
            gasLane,
            subscriptionId,
            callbackGasLimit,
            enableNativePayment
        );
        if(subscriptionId == 0) {
            CreateSubscription createSubscription = new CreateSubscription();
            subscriptionId = createSubscription.createSubscription(vrfCoordinatorV2);

            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundSubscription(vrfCoordinatorV2, subscriptionId, link, FUND_AMOUNT);
        }
        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(vrfCoordinatorV2, subscriptionId, address(raffle));
        vm.stopBroadcast();

        return (raffle,helperConfig);
    }
}
