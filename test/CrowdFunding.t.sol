//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from 'forge-std/Test.sol';
import {CrowdFunding} from '../src/CrowdFunding.sol';
import {console} from "forge-std/console.sol";

contract TestCrowdFunding is Test {
    CrowdFunding crowdFunding;
    function setUp() external {
        crowdFunding = new CrowdFunding();
    }
    function testCreateProject() public{
        address creator = address(1);
        string memory description = "My first project";
        uint256 goal = 10 ether;
        uint256 deadline = 86400;
        vm.prank(creator);
        crowdFunding.createProject(description, goal, deadline);
        assertEq(crowdFunding.getProjectCreator(1), creator);
        assertEq(crowdFunding.getProjectGoal(1), goal);
        assertEq(crowdFunding.getProjectDeadline(1), deadline);
    }
    function testContributeToProject() public{
        address creator = address(1);
        string memory description = "My first project";
        uint256 goal = 10 ether;
        uint256 deadline = 86400;
        vm.prank(creator);
        crowdFunding.createProject(description, goal, deadline);
        address contributor = address(2);
        uint256 contribution = 1 ether;
        hoax(contributor, contribution);
        crowdFunding.contribute{value: contribution}(1);
        assertEq(crowdFunding.getContribution(1, contributor), contribution);
        assertEq(crowdFunding.getProjectAmountRaised(1), contribution);
    }
    function testRefundContribution() public {
        address creator = address(1);
        string memory description = "My first project";
        uint256 goal = 10 ether;
        uint256 deadline = 86400;
        vm.prank(creator);
        crowdFunding.createProject(description, goal, deadline);
        address contributor = address(2);
        uint256 contribution = 1 ether;
        hoax(contributor, contribution);
        crowdFunding.contribute{value: contribution}(1);
        vm.prank(contributor);
        crowdFunding.refund(1);
        assertEq(crowdFunding.getContribution(1, contributor), 0);
        assertEq(contributor.balance, contribution);
    }
    function testDoubleRefund() public {
        address creator = address(1);
        string memory description = "My first project";
        uint256 goal = 10 ether;
        uint256 deadline = 86400;
        vm.prank(creator);
        crowdFunding.createProject(description, goal, deadline);
        address contributor = address(2);
        uint256 contribution = 1 ether;
        hoax(contributor, contribution);
        crowdFunding.contribute{value: contribution}(1);
        vm.prank(contributor);
        crowdFunding.refund(1);
        vm.prank(contributor);
        vm.expectRevert();
        crowdFunding.refund(1);
        assertEq(crowdFunding.getContribution(1, contributor), 0);
        assertEq(contributor.balance, contribution);
    }
    function testWithdraw() public {
        address creator = address(1);
        string memory description = "My first project";
        uint256 goal = 1 ether;
        uint256 deadline = 86400;
        vm.prank(creator);
        crowdFunding.createProject(description, goal, deadline);
        address contributor = address(2);
        uint256 contribution = 1 ether;
        hoax(contributor, contribution);
        crowdFunding.contribute{value: contribution}(1);
    }
    function testProjectGoalReachedAndWithdrawl() public{
        address creator = address(1);
        string memory description = "My first project";
        uint256 goal = 0.1 ether;
        uint256 deadline = 86400;
        vm.prank(creator);
        crowdFunding.createProject(description, goal, deadline);
        address contributor = address(2);
        uint256 contribution = 0.1 ether;
        hoax(contributor, contribution);
        crowdFunding.contribute{value: contribution}(1);
        assertEq(crowdFunding.getProjectGoalReached(1), true);
        vm.warp(deadline + 60);
        vm.prank(creator);
        crowdFunding.withdraw(1);
        assertEq(creator.balance, contribution);
        assertEq(crowdFunding.getProjectDeadlineReached(1), true);
        assertEq(crowdFunding.getProjectFundsWithdrawn(1), true);
    }
    function testDoubleWithdrawl() public {
        address creator = address(1);
        string memory description = "My first project";
        uint256 goal = 0.1 ether;
        uint256 deadline = 86400;
        vm.prank(creator);
        crowdFunding.createProject(description, goal, deadline);
        address contributor = address(2);
        uint256 contribution = 0.1 ether;
        hoax(contributor, contribution);
        crowdFunding.contribute{value: contribution}(1);
        assertEq(crowdFunding.getProjectGoalReached(1), true);
        vm.warp(deadline + 60);
        vm.prank(creator);
        crowdFunding.withdraw(1);
        vm.prank(creator);
        vm.expectRevert();
        crowdFunding.withdraw(1);
    }
}