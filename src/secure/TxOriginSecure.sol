// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TxOriginSecure {
    address public immutable owner;

    error Unauthorized();

    constructor() {
        owner = msg.sender;
    }

    // Access control using msg.sender
    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert Unauthorized();
        }
        _;
    }

    // Users can deposit ETH
    function deposit() external payable {
        require(msg.value > 0, "Deposit must be greater than zero");
    }

    // Only the owner can withdraw ETH
    function withdrawAll(address payable recipient) external onlyOwner {
        uint256 amount = address(this).balance;

        require(amount > 0, "Vault is empty");
        require(recipient != address(0), "Invalid recipient");

        (bool success,) = recipient.call{value: amount}("");

        require(success, "Transfer failed");
    }
}
