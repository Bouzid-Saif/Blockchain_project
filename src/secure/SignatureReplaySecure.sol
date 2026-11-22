// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SignatureReplaySecure {
    address public immutable owner;

    uint256 public nonce;

    error InvalidSignature();
    error TransferFailed();

    // EIP-712 domain and message definitions
    bytes32 private constant DOMAIN_TYPEHASH =
        keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    bytes32 private constant WITHDRAW_TYPEHASH = keccak256("Withdraw(address recipient,uint256 amount,uint256 nonce)");

    bytes32 private constant NAME_HASH = keccak256("EtherShield");
    bytes32 private constant VERSION_HASH = keccak256("1");

    // Maximum accepted s value to prevent signature malleability
    uint256 private constant SECP256K1_HALF_ORDER = 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0;

    constructor(address owner_) {
        require(owner_ != address(0), "Invalid owner");
        owner = owner_;
    }

    // Deposit ETH into the vault
    function deposit() external payable {
        require(msg.value > 0, "Deposit must be greater than zero");
    }

    // Generate an EIP-712-style digest
    function getDigest(address payable recipient, uint256 amount) public view returns (bytes32) {
        bytes32 domainSeparator =
            keccak256(abi.encode(DOMAIN_TYPEHASH, NAME_HASH, VERSION_HASH, block.chainid, address(this)));

        bytes32 structHash = keccak256(abi.encode(WITHDRAW_TYPEHASH, recipient, amount, nonce));

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }

    // Recover the signer with basic ECDSA validation
    function recoverSigner(bytes32 digest, uint8 v, bytes32 r, bytes32 s) private pure returns (address) {
        if ((v != 27 && v != 28) || uint256(s) > SECP256K1_HALF_ORDER) {
            return address(0);
        }

        return ecrecover(digest, v, r, s);
    }

    // Withdraw ETH using a signed authorization
    function withdrawWithSignature(address payable recipient, uint256 amount, uint8 v, bytes32 r, bytes32 s) external {
        require(recipient != address(0), "Invalid recipient");
        require(amount > 0, "Invalid amount");

        require(address(this).balance >= amount, "Insufficient vault balance");

        // Verify the signature
        address signer = recoverSigner(getDigest(recipient, amount), v, r, s);

        if (signer != owner) {
            revert InvalidSignature();
        }

        // Effects: consume the authorization
        nonce++;

        // Interactions: transfer ETH
        (bool success,) = recipient.call{value: amount}("");

        if (!success) {
            revert TransferFailed();
        }
    }
}
