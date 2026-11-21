// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TxOriginVulnerable {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    // Users can deposit ETH
    function deposit() external payable {
        require(msg.value > 0, "Deposit must be greater than zero");
    }

    // VULNERABILITY: tx.origin used for authorization
    function withdrawAll(address payable recipient) external {
        require(tx.origin == owner, "Not owner");

        uint256 amount = address(this).balance;

        require(amount > 0, "Vault is empty");
        require(recipient != address(0), "Invalid recipient");

        // Transfer all ETH to recipient
        (bool success,) = recipient.call{value: amount}("");

        require(success, "Transfer failed");
    }
}

