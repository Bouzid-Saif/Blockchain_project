// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FrontRunningSecure {
    uint256 public immutable commitEnd;
    uint256 public immutable revealEnd;

    uint256 public highestBid;
    address public highestBidder;

    mapping(address => bytes32) public commitments;
    mapping(address => bool) public revealed;

    error CommitPhaseClosed();
    error RevealPhaseNotStarted();
    error RevealPhaseClosed();
    error AlreadyCommitted();
    error NoCommitment();
    error AlreadyRevealed();
    error InvalidCommitment();
    error InvalidBid();

    constructor(uint256 commitDuration, uint256 revealDuration) {
        require(commitDuration > 0, "Invalid commit duration");
        require(revealDuration > 0, "Invalid reveal duration");

        commitEnd = block.timestamp + commitDuration;
        revealEnd = commitEnd + revealDuration;
    }

    // Generate a commitment without revealing the bid
    function computeCommitment(address bidder, uint256 amount, bytes32 secret) public view returns (bytes32) {
        return keccak256(abi.encode(block.chainid, address(this), bidder, amount, secret));
    }

    // Phase 1: Submit a hidden commitment
    function commitBid(bytes32 commitment) external {
        if (block.timestamp >= commitEnd) {
            revert CommitPhaseClosed();
        }

        if (commitments[msg.sender] != bytes32(0)) {
            revert AlreadyCommitted();
        }

        if (commitment == bytes32(0)) {
            revert InvalidCommitment();
        }

        commitments[msg.sender] = commitment;
    }

    // Phase 2: Reveal the original bid
    function revealBid(uint256 amount, bytes32 secret) external {
        if (block.timestamp < commitEnd) {
            revert RevealPhaseNotStarted();
        }

        if (block.timestamp >= revealEnd) {
            revert RevealPhaseClosed();
        }

        bytes32 commitment = commitments[msg.sender];

        if (commitment == bytes32(0)) {
            revert NoCommitment();
        }

        if (revealed[msg.sender]) {
            revert AlreadyRevealed();
        }

        if (amount == 0) {
            revert InvalidBid();
        }

        bytes32 expectedCommitment = computeCommitment(msg.sender, amount, secret);

        if (commitment != expectedCommitment) {
            revert InvalidCommitment();
        }

        // Mark this bid as revealed
        revealed[msg.sender] = true;

        // Update the auction result
        if (amount > highestBid) {
            highestBid = amount;
            highestBidder = msg.sender;
        }
    }
}

