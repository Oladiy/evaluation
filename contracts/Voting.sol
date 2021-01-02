pragma solidity ^0.8.0;

contract Voting {
    address payable public beneficiary;

    uint public biddingEnd;
    uint public revealEnd;
    /// Максимально возможное значение голоса
    uint public scaleMaxValue;

    string public beneficiaryName;

    modifier checkBalance() {
        require(msg.sender.balance >= scaleMaxValue);
        _;
    }

    modifier onlyBefore(uint _time) {
        require(block.timestamp < _time);
        _;
    }

    modifier onlyAfter(uint _time) {
        require(block.timestamp > _time);
        _;
    }

    constructor(
        uint _biddingTime,
        uint _revealTime,
        uint _scaleMaxValue,
        address payable _beneficiary,
        string memory _beneficiaryName
    ) {
        biddingEnd = block.timestamp + _biddingTime;
        revealEnd = biddingEnd + _revealTime;
        scaleMaxValue = _scaleMaxValue;
        beneficiary = _beneficiary;
        beneficiaryName = _beneficiaryName;
    }
}
