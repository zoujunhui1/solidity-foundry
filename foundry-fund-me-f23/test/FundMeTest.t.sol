// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe public fundMe;

    address USER = makeAddr("user"); // 测试用户地址
    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE); // 测试用户地址的初始余额
    }

    function testMinimumDollarIsFive() public view {
        assertEq(fundMe.MINIMUM_USD(), 5 * 10 ** 18);
    }

    function testOwnerIsCaller() public view {
        assertEq(fundMe.i_owner(), msg.sender);
    }

    /**
     * forge test --match-test testPriceFeedVersionIsAccurate -vvvv --rpc-url $SEPOLIA_RPC_URL
     *
     * @notice 测试 FundMe 合约的 getVersion() 函数是否返回正确的版本号 4.
     * ### 不加 --rpc-url（本地测试）
     * ### 加上 --rpc-url（真实测试网）
     */
    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughtEth() public {
        vm.expectRevert("You need to spend more ETH!");
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); // 测试用户地址进行 fund 操作
        fundMe.fund{value: SEND_VALUE}();
        uint256 amountFunded = fundMe.addressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }
}

