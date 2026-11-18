// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ReentrancySecure {
    mapping(address => uint256) public balances;

    // Deposit ETH into the vault
    function deposit() external payable {
        require(msg.value > 0, "Deposit must be greater than zero");
        balances[msg.sender] += msg.value;
    }

    // Withdraw ETH securely
    function withdraw() external {
        uint256 amount = balances[msg.sender];

        require(amount > 0, "Insufficient balance");

        // Effects: update balance BEFORE external call
        balances[msg.sender] = 0;

        // Interaction: transfer ETH
        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
    }

    // Check the ETH balance of the vault
    function getVaultBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
