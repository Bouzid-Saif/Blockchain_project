// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SignatureReplayVulnerable {
    address public immutable owner;

    constructor(address owner_) {
        require(owner_ != address(0), "Invalid owner");
        owner = owner_;
    }

    // Deposit ETH into the vault
    function deposit() external payable {
        require(msg.value > 0, "Deposit must be greater than zero");
    }

    // Vulnerable: no nonce, no chain ID, no contract address
    function getDigest(address payable recipient, uint256 amount) public pure returns (bytes32) {
        bytes32 messageHash = keccak256(abi.encode(recipient, amount));

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
    }

    // Anyone can submit the owner's signature
    function withdrawWithSignature(address payable recipient, uint256 amount, uint8 v, bytes32 r, bytes32 s) external {
        require(recipient != address(0), "Invalid recipient");
        require(amount > 0, "Invalid amount");
        require(address(this).balance >= amount, "Insufficient vault balance");

        // Verify the owner's signature
        address signer = ecrecover(getDigest(recipient, amount), v, r, s);

        require(signer == owner, "Invalid signature");

        // Vulnerability: the same signature can be reused
        (bool success,) = recipient.call{value: amount}("");

        require(success, "Transfer failed");
    }
}
