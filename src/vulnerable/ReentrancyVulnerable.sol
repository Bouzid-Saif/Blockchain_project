pragma solidity ^0.8.20;

contract ReentrancyVulnerable {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        require(msg.value > 0, "Deposit must be greater than zero");
        balances[msg.sender] += msg.value;
    }

    function withdraw() external {
        uint256 amount = balances[msg.sender];

        require(amount > 0, "Insufficient balance");

        (bool success,) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        balances[msg.sender] = 0;
    }

    function getVaultBalance() external view returns (uint256) {
        return address(this).balance;
    }
}

