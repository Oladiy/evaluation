pragma solidity ^0.7.0;

contract CommitRevealEvaluation {
    /// Адрес того, за кого голосуют
    address payable public beneficiary;

    /// Таблица тех, кто голосовал
    mapping(address => bool) public evaluators;

    /// Таблица голос + депозит
    mapping(address => Evaluation) public evaluations;

    /// Окончание возможности сделать голос
    uint public evaluationEnd;
    /// Окончание возможности раскрытия
    uint public revealEnd;
    /// Максимально возможное значение голоса
    uint public scaleMaxValue;

    struct Evaluation {
        string evaluation;
        uint deposit;
    }

    /// Имя того, за кого голосуют (beneficiary)
    string public beneficiaryName;

    modifier checkBalance() {
        require(msg.sender.balance >= scaleMaxValue);
        _;
    }

    modifier checkDidNotEvaluate() {
        require(!evaluators[msg.sender]);
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
        uint _evaluationTime,
        uint _revealTime,
        uint _scaleMaxValue,
        address payable _beneficiary,
        string memory _beneficiaryName
    ) {
        evaluationEnd = block.timestamp + _evaluationTime;
        revealEnd = evaluationEnd + _revealTime;
        scaleMaxValue = _scaleMaxValue;
        beneficiary = _beneficiary;
        beneficiaryName = _beneficiaryName;
    }

    /// Выставить оценку beneficiary.
    /// _evaluate нужно задать = keccak256(abi.encodePacked(value, fake, secret))
    /// Невозможно отменить выставленную оценку. Невозможно оценить дважды.
    function evaluate(
        string memory _evaluation // возможно нужно bytes32 - подумать!
    )
    public
    payable
    onlyBefore(evaluationEnd)
    checkBalance()
    checkDidNotEvaluate()
    {
        evaluations[msg.sender] = Evaluation({
            evaluation: _evaluation,
            deposit: msg.value
        });
        evaluators[msg.sender] = true;
    }

    function reveal(

    )
    public
    onlyAfter(evaluationEnd)
    onlyBefore(revealEnd)
    {

    }

    function endEvaluation(

    )
    public
    onlyAfter(revealEnd)
    {

    }

    /// Проверить снаружи, произошло ли какое-то событие относительно block.timestamp
    function isHappened(uint _time)
    public
    view
    returns (bool)
    {
        return (block.timestamp >= _time);
    }
}
