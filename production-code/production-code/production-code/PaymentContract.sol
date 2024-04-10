// PaymentContract.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PaymentContract {
    address public collegeAccount;
    mapping(address => uint256) public balances;

    event PaymentMade(address indexed account, uint256 amount);

    constructor() {
        // Set the college account to the provided address
        collegeAccount = 0xecc59DD60A07AA629340940eD648c01Af923F886;
    }

    modifier onlyCollege() {
        require(msg.sender == collegeAccount, "Only college can call this function");
        _;
    }

    function makePayment() external payable {
        require(msg.value > 0, "Payment amount must be greater than 0");

        // Update student balance
        balances[msg.sender] += msg.value;

        // Emit PaymentMade event
        emit PaymentMade(msg.sender, msg.value);
    }

    function withdrawFunds() external onlyCollege {
        // College can withdraw funds from the contract
        require(address(this).balance > 0, "No funds available for withdrawal");
        payable(collegeAccount).transfer(address(this).balance);
    }
}