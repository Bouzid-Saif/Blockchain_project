// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FrontRunningVulnerable {
    uint256 public highestBid;
    address public highestBidder;

    // Public auction: bids are visible in transaction data
    function bid() external payable {
        require(msg.value > highestBid, "Bid too low");

        highestBid = msg.value;
        highestBidder = msg.sender;
    }
}

