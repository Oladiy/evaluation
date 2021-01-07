pragma solidity ^0.7.0;

import "./abdk-libraries-solidity/ABDKMathQuad.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract CommitRevealEvaluation {
    using SafeMath for uint256;

    event EvaluationEnded(address participant, uint result, string participantName);

    /// Адрес того, кого оценивают
    address payable public beneficiary;
    address[] juriesList;
    /// Адрес владельца контракта
    address public owner;

    /// true, если оценивание закончилось
    bool public evaluationEnded;

    /// Баланс по умолчанию [Токены]
    uint constant public DEFAULT_TOKEN_BALANCE = 100000;

    /// Таблица жюри, которые сделали evaluate
    mapping(address => bool) public evaluators;
    /// Таблица тех, кто сделал reveal
    mapping(address => bool) public evaluatorsRevealed;
    /// Таблица оценка + депозит
    mapping(address => Evaluation) public evaluations;
    /// mapping адресов жюри, чтобы быстро проверить, есть ли они в списке
    mapping(address => bool) public juries;
    /// Балансы жюри [Токены]
    mapping(address => uint) public balances;

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
        require(balances[msg.sender] >= scaleMaxValue, "Balance is less than scale max value");
        _;
    }

    modifier onlyBefore(uint _time) {
        require(block.timestamp < _time, "Only before is required");
        _;
    }

    modifier onlyAfter(uint _time) {
        require(block.timestamp > _time, "Only after is required");
        _;
    }

    constructor(
        uint _evaluationTime,
        uint _revealTime,
        uint _scaleMaxValue,
        address payable _beneficiary,
        string memory _beneficiaryName,
        address [] memory _juries
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
            balances[_juries[i]] = DEFAULT_TOKEN_BALANCE;
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
    //onlyBefore(evaluationEnd)
    checkBalance()
    {
        /// Проверка, если ли msg.sender в списке жюри
        require(juries[msg.sender], "Caller is not the jury");
        /// Проверка, что жюри еще не оценил
        require(!evaluators[msg.sender], "Jury has already evaluated");

        evaluations[msg.sender] = Evaluation({
            evaluation: _evaluation,
            deposit: balances[msg.sender]
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
        require(juries[msg.sender], "Caller is not the jury");
        /// Проверка, что жюри еще не сделал reveal
        require(!evaluatorsRevealed[msg.sender], "Jury has already revealed");

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
        require(!evaluationEnded, "Evaluation hasn't been ended yet");

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
        address jury;
        uint value = divide(result, juriesAmount);
        uint refundAmount;

        for (uint i = 0; i < juriesAmount; i++) {
            jury = juriesList[i];

            if (!evaluatorsRevealed[jury]) {
                continue;
            }

            deposit = evaluations[jury].deposit;

            if (deposit <= value) {
                continue;
            }

            refundAmount = deposit - value;

            evaluations[jury].deposit = 0;
            balances[jury] += refundAmount;
        }
    }

    /// Добавить жюри в список
    function addJury(
        address _jury
    )
    public
    {
        require(msg.sender == owner, "Caller is not the owner");
        require(!juries[_jury]);

        juriesList.push(_jury);
        juries[_jury] = true;
        juriesAmount++;
    }

    /// Удалить жюри из списка
    function removeJury(
        address _jury
    )
    public
    {
        require(msg.sender == owner, "Caller is not the owner");
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
    function resetJuryBalance(
        address _jury
    )
    public
    {
        require(msg.sender == owner, "Caller is not the owner");

        balances[_jury] = DEFAULT_TOKEN_BALANCE;
    }

    /// Проверить снаружи, произошло ли какое-то событие относительно block.timestamp
    function isHappened(uint _time)
    public
    view
    returns (bool)
    {
        return block.timestamp >= _time;
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
