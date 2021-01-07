pragma solidity ^0.7.0;

import "./abdk-libraries-solidity/ABDKMathQuad.sol";

contract CommitRevealEvaluation {
    event EvaluationEnded(address participant, uint result, string participantName);

    /// Адрес того, кого оценивают
    address payable public beneficiary;
    /// Адреса жюри
    address payable [] public juriesList;
    /// Адрес владельца контракта
    address payable public owner;

    /// true, если оценивание закончилось
    bool public evaluationEnded;

    /// Таблица жюри, которые сделали evaluate
    mapping(address => bool) public evaluators;
    /// Таблица тех, кто сделал reveal
    mapping(address => bool) public evaluatorsRevealed;
    /// Таблица оценка + депозит
    mapping(address => Evaluation) public evaluations;
    /// mapping адресов жюри, чтобы быстро проверить, есть ли они в списке
    mapping(address => bool) public juries;

    /// Окончание возможности оценить
    uint public evaluationEnd;
    /// Окончание возможности раскрытия
    uint public revealEnd;
    /// Максимально возможное значение оценки
    uint public scaleMaxValue;
    /// Сумма всех оценок
    uint public evaluationSum;
    /// Количество жюри
    uint public juriesAmount;
    /// Итоговая оценка (среднее арифметическое)
    uint public result;

    /// Имя того, кого оценивают (beneficiary)
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
        owner = msg.sender;
        evaluationEnd = block.timestamp + _evaluationTime;
        revealEnd = evaluationEnd + _revealTime;
        scaleMaxValue = _scaleMaxValue;
        beneficiary = _beneficiary;
        beneficiaryName = _beneficiaryName;

        juriesList = _juries;
        juriesAmount = _juries.length;
        for (uint i = 0; i < juriesAmount; ++i) {
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
        require(msg.value >= scaleMaxValue);

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
        /// Проверка, что жюри еще не сделал reveal
        require(!evaluatorsRevealed[msg.sender]);

        /// Проверка, что раскрыто то значение, которое загадывалось
        if (evaluations[msg.sender].evaluation != keccak256(abi.encodePacked(value, fake, secret))) {
            return;
        }

        evaluationSum += value;
        evaluatorsRevealed[msg.sender] = true;
    }

    /// Окончание оценивания.
    /// Вычисляется среднее арифметическое всех оценок.
    /// Результат переводится beneficiary, причем сумма равномерно распределяется между жюри.
    /// Остатки возвращаются на счета жюри в зависимости от их депозита.
    function endEvaluation()
    public
    onlyAfter(revealEnd)
    {
        require(!evaluationEnded);

        result = divide(evaluationSum, juriesAmount);

        emit EvaluationEnded(beneficiary, result, beneficiaryName);
        evaluationEnded = true;

        refund();
        beneficiary.transfer(result);
    }

    /// Подсчет и возват средств жюри, которые выходят за границу result
    function refund()
    internal
    {
        uint deposit;
        address payable jury;
        uint length = juriesList.length;
        uint value = divide(result, juriesAmount);
        uint refundAmount;

        for (uint i = 0; i < length; i++) {
            jury = payable(juriesList[i]);

            if (!evaluatorsRevealed[jury]) {
                continue;
            }

            deposit = evaluations[jury].deposit;

            if (deposit <= value) {
                continue;
            }

            refundAmount = deposit - value;

            // Защищаемся от double-spending
            evaluations[jury].deposit = 0;
            jury.transfer(refundAmount);
            refundAmount = 0;
        }
    }

    /// Добавить жюри в список
    function addJury(
        address _jury
    )
    public
    {
        require(msg.sender == owner);
        require(!juries[_jury]);

        juriesList.push(payable(_jury));

        juries[_jury] = true;
        juriesAmount++;
    }

    /// Удалить жюри из списка
    function removeJury(
        address payable _jury
    )
    public
    {
        require(msg.sender == owner);
        require(juries[_jury]);

        juries[_jury] = false;
        evaluators[_jury] = false;
        evaluatorsRevealed[_jury] = false;
        evaluations[_jury].deposit = 0;

        for (uint i = 0; i < juriesAmount; ++i) {
            if (_jury != juriesList[i]) {
                continue;
            }
            delete juriesList[i];
        }
        juriesAmount--;
    }

    /// Сброс баланса до значения по умолчанию
    function resetJuryBalance()
    public
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

    /// Выполняем деление, используя библиотеку ABDKMathQuad
    function divide(
        uint numerator,
        uint denominator
    )
    internal
    pure
    returns (uint)
    {
        return ABDKMathQuad.toUInt(
            ABDKMathQuad.div(
                ABDKMathQuad.fromUInt(numerator),
                ABDKMathQuad.fromUInt(denominator)
            )
        );
    }
}
