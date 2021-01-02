pragma solidity ^0.8.0;

contract Voting {
    /// Адрес того, за кого голосуют
    address payable public beneficiary;

    /// Таблица тех, кто голосовал
    mapping(address => bool) public voters;

    /// Таблица голос + депозит
    mapping(address => Vote) public votes;

    /// Окончание возможности сделать голос
    uint public votingEnd;
    /// Окончание возможности раскрытия
    uint public revealEnd;
    /// Максимально возможное значение голоса
    uint public scaleMaxValue;

    struct Vote {
        string vote;
        uint deposit;
    }

    /// Имя того, за кого голосуют (beneficiary)
    string public beneficiaryName;

    modifier checkBalance() {
        require(msg.sender.balance >= scaleMaxValue);
        _;
    }

    modifier checkDidNotVote() {
        require(!voters[msg.sender]);
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

    /// Выставить оценку beneficiary.
    /// _vote нужно задать = keccak256(abi.encodePacked(value, fake, secret))
    /// Невозможно отменить выставленную оценку. Невозможно оценить дважды.
    function vote(
        string memory _vote // возможно нужно bytes32 - подумать!
    )
    public
    payable
    onlyBefore(votingEnd)
    checkBalance()
    checkDidNotVote()
    {
        votes[msg.sender] = Vote({
            vote: _vote,
            deposit: msg.value
        });
        voters[msg.sender] = true;
    }

    function reveal(

    )
    public
    onlyAfter(votingEnd)
    onlyBefore(revealEnd)
    {

    }

    function endVoting(

    )
    public
    onlyAfter(revealEnd)
    {

    }

    function isHappened(uint _time)
    public
    view
    returns (bool)
    {
        return (block.timestamp >= _time);
    }
}
