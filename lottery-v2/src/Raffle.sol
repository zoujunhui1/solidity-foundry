// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import {AutomationCompatibleInterface} from "@chainlink/contracts/src/v0.8/automation/interfaces/AutomationCompatibleInterface.sol";

/** 
 * @title Raffle
 * @author ZHJ
 * @notice A proveable random raffle contract lottery.
 */
contract Raffle is VRFConsumerBaseV2Plus, AutomationCompatibleInterface {
    error Raffle__NotEnoughETHSent();
    error Raffle__NotOpen();
    error Raffle__TransactionFailed();
    error Raffle__UpkeepNotNeeded(uint256 currentBalance,uint256 numPlayers,uint256 raffleState);  


    enum RaffleState {
        OPEN,
        CALCULATING
    }

    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;


    uint256 private immutable i_entranceFee;//参与抽奖的费用
    uint256 private immutable i_interval;//抽奖间隔时间
    uint256 private immutable i_subscriptionId;//订阅id 
    bytes32 private immutable i_gasLane;//gas lane
    uint32 private immutable i_callbackGasLimit;//回调gas limit
    bool private immutable i_enableNativePayment;//是否启用原生支付     

    address payable[] private s_players;//参与抽奖的玩家
    uint256 private s_lastTimeStamp;//上一次抽奖的时间      
    address private s_recentWinner;//最近的赢家

    RaffleState private s_state;//当前状态

    event EnterRaffle(address indexed player);
    event PickWinner(address indexed winner);

    constructor(
        uint256 entranceFee,        
        uint256 interval,
        address vrfCoordinatorV2,
        bytes32 gasLane,
        uint256 subscriptionId,
        uint32 callbackGasLimit,
        bool enableNativePayment
    ) VRFConsumerBaseV2Plus(vrfCoordinatorV2) {
        i_entranceFee = entranceFee;
        i_interval = interval;  
        i_subscriptionId = subscriptionId;
        i_gasLane = gasLane;
        i_callbackGasLimit = callbackGasLimit;
        i_enableNativePayment = enableNativePayment;                

        s_state = RaffleState.OPEN;
        s_lastTimeStamp = block.timestamp;
    } 

    function enterRaffle() external payable{
        if (msg.value < i_entranceFee) {
            revert Raffle__NotEnoughETHSent();
        }
        if(s_state != RaffleState.OPEN) {
            revert Raffle__NotOpen();
        }
        s_players.push(payable(msg.sender));
        emit EnterRaffle(msg.sender);
    }

    //chainlink automation 会先调用这个方法，如果返回true，就会调用performUpkeep方法
    function checkUpkeep(
        bytes memory /* checkData */
    )
        public
        view
        override
        returns (
        bool upkeepNeeded,
        bytes memory /* performData */
        )
    {
        bool timeHaspassed = (block.timestamp - s_lastTimeStamp) >= i_interval;
        bool isOpen = s_state == RaffleState.OPEN;
        bool hasBalance = address(this).balance > 0;
        upkeepNeeded = timeHaspassed && isOpen && hasBalance;
        return (upkeepNeeded, "0x0");
    }
    //get a random number
    //use the random number to pick a player
    //be automatically called
    function performUpkeep(bytes calldata /* performData */) external override {
        (bool upkeepNeeded,) = checkUpkeep("");
        if(!upkeepNeeded) {
            revert Raffle__UpkeepNotNeeded(
                address(this).balance,
                s_players.length,
                uint256(s_state)
            );
        }
        s_state = RaffleState.CALCULATING;
        
        uint256 requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: i_gasLane,
                subId: i_subscriptionId,
                requestConfirmations: REQUEST_CONFIRMATIONS,
                callbackGasLimit: i_callbackGasLimit,
                numWords: NUM_WORDS,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: i_enableNativePayment})
                )
            })
        );
    }

    function fulfillRandomWords(
        uint256 /* requestId */,
        uint256[] calldata randomWords
    ) internal override {
        uint256 indexOfwinner = randomWords[0] % s_players.length;//拿到随机数，选择一个玩家
        s_recentWinner = s_players[indexOfwinner];
        s_state = RaffleState.OPEN;
        s_lastTimeStamp = block.timestamp;//更新上一次抽奖的时间
        
        s_players = new address payable[](0);//清空玩家数组
        emit PickWinner(s_recentWinner);

        (bool success,) = s_recentWinner.call{value: address(this).balance}("");
        if(!success) {
            revert Raffle__TransactionFailed();
        }

    }

    function getEntranceFee() public view returns (uint256) {
        return i_entranceFee;
    }

    function getRaffleState() public view returns (uint256) {
        return uint256(s_state);
    }

    function getPlayer(uint256 indexOfPlayer) external view returns (address) {
        return s_players[indexOfPlayer];
    }
}
