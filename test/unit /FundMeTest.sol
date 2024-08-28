// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test  {
    FundMe fundMe;  

    address USER = makeAddr("user");
    uint256 constant SEND_AMOUNT = 0.1 ether;
    uint256 constant STARTING_BAL = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BAL);
    }

    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwner() public {
        // console.log("Owner address:", fundMe.i_owner());
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
      uint256 version = fundMe.getVersion();
      assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert();
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); 
        fundMe.fund{value: SEND_AMOUNT}();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_AMOUNT);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_AMOUNT}();

        address funder = fundMe.getFunder(0);
        assertEq(funder,USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_AMOUNT}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded{
        //Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundmeBalance = address(fundMe).balance;

        //Act
        uint256 gasStart = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();
        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log(gasUsed);

        //Assert 
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundmeBalance = address(fundMe).balance;
        assertEq(endingFundmeBalance, 0);
        assertEq(startingOwnerBalance + startingFundmeBalance, endingOwnerBalance);
    }

    function testWithdrawWithMultipleFunders() public funded {
        //Arrange 
        uint160 numberOfFunders = 10;
        uint160 startingIndexOfFunder = 1;
        for(uint160 i = startingIndexOfFunder; i < numberOfFunders; i++){
            //instead of doing vm.prank and vm.deal we do vm.hoax 
            //vm.hoax => means it is combine of both 
            hoax(address(i), SEND_AMOUNT);
            fundMe.fund{value:SEND_AMOUNT}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundmeBalance = address(fundMe).balance;

        //Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        //assert
        assert(address(fundMe).balance == 0);
        assert(startingOwnerBalance + startingFundmeBalance == fundMe.getOwner().balance);
    }

    function testWithdrawWithMultipleFundersCheaper() public funded {
        //Arrange 
        uint160 numberOfFunders = 10;
        uint160 startingIndexOfFunder = 1;
        for(uint160 i = startingIndexOfFunder; i < numberOfFunders; i++){
            //instead of doing vm.prank and vm.deal we do vm.hoax 
            //vm.hoax => means it is combine of both 
            hoax(address(i), SEND_AMOUNT);
            fundMe.fund{value:SEND_AMOUNT}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundmeBalance = address(fundMe).balance;

        //Act
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        //assert
        assert(address(fundMe).balance == 0);
        assert(startingOwnerBalance + startingFundmeBalance == fundMe.getOwner().balance);
    }

}