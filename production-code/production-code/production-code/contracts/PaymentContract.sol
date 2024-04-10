// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PaymentContract {
    address public college;
    mapping(address => uint256) public balances;

    event PaymentMade(address indexed student, uint256 amount);

    modifier onlyCollege() {
        require(msg.sender == college, "Only the college can call this function");
        _;
    }

    constructor() {
        college = msg.sender;
    }

    function makePayment() external payable {
        require(msg.value > 0, "Payment amount must be greater than 0");
        balances[msg.sender] += msg.value;
        emit PaymentMade(msg.sender, msg.value);
    }

    function withdrawFunds() external onlyCollege {
        require(college != address(0), "College address not set");
        require(address(this).balance > 0, "No funds to withdraw");
        
        payable(college).transfer(address(this).balance);
    }
}
