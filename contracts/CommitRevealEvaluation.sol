pragma solidity ^0.7.0;

import "./abdk-libraries-solidity/ABDKMathQuad.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract CommitRevealEvaluation {
    using SafeMath for uint256;

    event EvaluationEnded(address participant, uint result, string participantName);

    /// Адрес оцениваемого
    address payable public beneficiary;
    address[] juriesList;
    /// Адрес владельца контракта
    address public owner;

    /// true, если оценивание закончилось и beneficiary вынесен вердикт
    bool public evaluationEnded;

    /// Баланс по умолчанию [Токены]
    uint constant public DEFAULT_TOKEN_BALANCE = 100000;

    /// Таблица жюри, которые сделали evaluate
    mapping(address => bool) public evaluators;
    /// Таблица жюри, которые сделали reveal
    mapping(address => bool) public evaluatorsRevealed;
    /// Таблица оценка + депозит
    mapping(address => Evaluation) public evaluations;
    /// Адреса жюри
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

    /// Имя оцениваемого (beneficiary)
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

        juriesList.push(owner);
        juries[owner] = true;
        balances[owner] = DEFAULT_TOKEN_BALANCE;
        juriesAmount++;
    }

    /// Выставить оценку beneficiary.
    /// _evaluate нужно задать = keccak256(abi.encodePacked(value, fake, secret)).
    /// value - uint; fake - bool: false, если выставляемая оценка не используется "для проверки", иначе - true;
    /// secret - string (nonce).
    /// Невозможно отменить выставленную оценку. Невозможно оценить дважды.
    function evaluate(
        bytes32 _evaluation
    )
    public
    onlyBefore(evaluationEnd)
    checkBalance()
    {
        // Проверка, если ли msg.sender в списке жюри
        require(juries[msg.sender], "Caller is not the jury");
        // Проверка, что жюри еще не оценил
        require(!evaluators[msg.sender], "Jury has already evaluated");

        evaluations[msg.sender] = Evaluation({
            evaluation: _evaluation,
            deposit: balances[msg.sender]
        });
        evaluators[msg.sender] = true;
    }

    /// Раскрытие оценки.
    /// Если раскрыто то значение, которое было в хеше - оно прибавляется к evaluationSum.
    function reveal(
        uint value,
        bool fake,
        string memory secret
    )
    public
    onlyAfter(evaluationEnd)
    onlyBefore(revealEnd)
    {
        // Проверка, если ли msg.sender в списке жюри
        require(juries[msg.sender], "Caller is not the jury");
        // Проверка, что жюри еще не сделал reveal
        require(!evaluatorsRevealed[msg.sender], "Jury has already revealed");

        if (evaluations[msg.sender].evaluation != keccak256(abi.encodePacked(value, fake, secret))) {
            return;
        }

        evaluationSum += value;
        evaluatorsRevealed[msg.sender] = true;
    }

    /// Окончание оценивания.
    /// Вычисляется среднее арифметическое всех оценок.
    /// Результат переводится beneficiary, причем сумма равномерно распределяется между жюри.
    /// Остатки возвращаются на балансы жюри в зависимости от их депозита.
    function endEvaluation()
    public
    onlyAfter(revealEnd)
    {
        require(!evaluationEnded, "Evaluation hasn't been ended yet");

        result = divide(evaluationSum, juriesAmount);

        evaluationEnded = true;

        refund();
        beneficiary.transfer(result);
        emit EvaluationEnded(beneficiary, result, beneficiaryName);
    }

    /// Подсчет и возват средств жюри
    function refund()
    internal
    {
        uint deposit;
        address jury;
        uint value = divide(result, juriesAmount);
        uint refundAmount;

        for (uint i = 0; i < juriesAmount; i++) {
            jury = juriesList[i];

            // Если жюри не прошел reveal - сокращаем баланс вдвоем и обнуляем депозит
            if (!evaluatorsRevealed[jury]) {
                balances[jury] = divide(balances[jury], 2);
                evaluations[jury].deposit = 0;
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
        balances[_jury] = DEFAULT_TOKEN_BALANCE;
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
