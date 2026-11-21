// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract AccessControlVulnerable {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    // Users can deposit ETH into the vault
    function deposit() external payable {
        require(msg.value > 0, "Deposit must be greater than zero");
    }

    // VULNERABILITY: Missing access control
    function withdrawAll(address payable recipient) external {
        uint256 amount = address(this).balance;

        require(amount > 0, "Vault is empty");
        require(recipient != address(0), "Invalid recipient");

        // No owner verification!
        (bool success,) = recipient.call{value: amount}("");

        require(success, "Transfer failed");
    }
}

