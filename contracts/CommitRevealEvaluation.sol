pragma solidity ^0.7.0;

contract CommitRevealEvaluation {
    /// Адрес того, за кого голосуют
    address payable public beneficiary;

    /// Таблица тех, кто голосовал
    mapping(address => bool) public evaluators;
    /// Таблица голос + депозит
    mapping(address => Evaluation) public evaluations;
    /// Адреса жюри
    mapping(address => bool) public juries;

    /// Окончание возможности сделать голос
    uint public evaluationEnd;
    /// Окончание возможности раскрытия
    uint public revealEnd;
    /// Максимально возможное значение голоса
    uint public scaleMaxValue;
    /// Сумма всех оценок
    uint public evaluationSum;
    /// Количество жюри
    uint public juriesAmount;

    /// Имя того, за кого голосуют (beneficiary)
    string public beneficiaryName;

    struct Evaluation {
        bytes32 evaluation;
        uint deposit;
    }

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
        string memory _beneficiaryName,
        address payable [] memory _juries
    ) {
        evaluationEnd = block.timestamp + _evaluationTime;
        revealEnd = evaluationEnd + _revealTime;
        scaleMaxValue = _scaleMaxValue;
        beneficiary = _beneficiary;
        beneficiaryName = _beneficiaryName;

        for (uint i = 0; i < _juries.length; ++i) {
            juries[_juries[i]] = true;
        }
    }

    /// Выставить оценку beneficiary.
    /// _evaluate нужно задать = keccak256(abi.encodePacked(value, fake, secret)).
    /// Невозможно отменить выставленную оценку. Невозможно оценить дважды.
    function evaluate(
        bytes32 _evaluation
    )
    public
    payable
    onlyBefore(evaluationEnd)
    checkBalance()
    checkDidNotEvaluate()
    {
        /// Проверка, если ли msg.sender в списке жюри
        require(juries[msg.sender]);

        evaluations[msg.sender] = Evaluation({
            evaluation: _evaluation,
            deposit: msg.value
        });
        evaluators[msg.sender] = true;
    }

    /// Раскрытие оценки.
    /// Если раскрыто то значение, которое загадывалось - оно прибавляется к evaluationSum.
    function reveal(
        uint value,
        bool fake,
        string memory secret
    )
    public
    onlyAfter(evaluationEnd)
    onlyBefore(revealEnd)
    {
        /// Проверка, если ли msg.sender в списке жюри
        require(juries[msg.sender]);

        /// Проверка, что раскрыто то значение, которое загадывалось
        if (evaluations[msg.sender].evaluation != keccak256(abi.encodePacked(value, fake, secret))) {
            return;
        }

        evaluationSum += value;
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
