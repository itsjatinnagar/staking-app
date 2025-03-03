// SPDX-License-Identifier: MIT
pragma solidity 0.8.20; //Do not change the solidity version as it negatively impacts submission grading

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {
    ExampleExternalContract public exampleExternalContract;

    event Stake(address indexed from, uint256 amount);

    mapping(address => uint256) public balances;
    uint256 public constant threshold = 1 ether;
    uint256 public deadline = block.timestamp + 30 seconds;
    bool openForWithdraw = false;

    constructor(address exampleExternalContractAddress) {
        exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
    }

    function stake() public payable {
        balances[msg.sender] += msg.value;
        emit Stake(msg.sender, msg.value);
    }

    function execute() public {
        require(exampleExternalContract.completed() == false, "Funding Completed");
        require(timeLeft() == 0, "Under Deadline");
        if (address(this).balance < threshold) {
            openForWithdraw = true;
        } else {
            exampleExternalContract.complete{ value: address(this).balance }();
        }
    }

    function withdraw() public {
        require(openForWithdraw, "Withdraw Closed");
        uint256 amount = balances[msg.sender];
        require(amount > 0, "Insufficient Balance");
        (bool success, ) = payable(msg.sender).call{ value: amount }("");
        require(success, "Withdraw Failed");
        balances[msg.sender] = 0;
    }

    function timeLeft() public view returns (uint256) {
        if (block.timestamp >= deadline) return 0;
        return deadline - block.timestamp;
    }

    // Add the `receive()` special function that receives eth and calls stake()
}
