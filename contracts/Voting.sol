pragma solidity ^0.8.0;

contract Voting {
    /// Адрес того, за кого голосуют
    address payable public beneficiary;

    /// Окончание возможности сделать голос
    uint public votingEnd;
    /// Окончание возможности раскрытия
    uint public revealEnd;
    /// Максимально возможное значение голоса
    uint public scaleMaxValue;

    /// Имя того, за кого голосуют
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
        uint _votingTime,
        uint _revealTime,
        uint _scaleMaxValue,
        address payable _beneficiary,
        string memory _beneficiaryName
    ) {
        votingEnd = block.timestamp + _votingTime;
        revealEnd = votingEnd + _revealTime;
        scaleMaxValue = _scaleMaxValue;
        beneficiary = _beneficiary;
        beneficiaryName = _beneficiaryName;
    }
}
