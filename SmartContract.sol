// Sample Solidity contract for recording simple transaction metadata
// This file is for demonstration only. Deploying it requires an Ethereum environment.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TxMetadata {
    struct TxInfo {
        address sender;
        address recipient;
        uint256 amount;
        uint8 rating;
        string category;
        uint256 timestamp;
    }

    TxInfo[] public txs;

    event TxRecorded(uint256 indexed id, address sender, address recipient, uint256 amount, uint8 rating, string category);

    function recordTx(address _recipient, uint256 _amount, uint8 _rating, string calldata _category) external {
        txs.push(TxInfo({
            sender: msg.sender,
            recipient: _recipient,
            amount: _amount,
            rating: _rating,
            category: _category,
            timestamp: block.timestamp
        }));
        emit TxRecorded(txs.length - 1, msg.sender, _recipient, _amount, _rating, _category);
    }

    function txCount() external view returns (uint256) {
        return txs.length;
    }

    function getTx(uint256 idx) external view returns (address, address, uint256, uint8, string memory, uint256) {
        TxInfo storage t = txs[idx];
        return (t.sender, t.recipient, t.amount, t.rating, t.category, t.timestamp);
    }
}
