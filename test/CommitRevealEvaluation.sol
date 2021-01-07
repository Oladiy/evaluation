pragma solidity ^0.7.0;

import "truffle/AssertAddress.sol";
import "truffle/AssertBool.sol";
import "truffle/AssertString.sol";
import "truffle/AssertUint.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/CommitRevealEvaluation.sol";

contract TestEvaluation {
    CommitRevealEvaluation evaluation = CommitRevealEvaluation(
        DeployedAddresses.CommitRevealEvaluation()
    );


    address firstJury = 0xD0D1597614662cf53C1ADA223D9268b984B68714;
    address secondJury = 0x2c61097258C54cE52143224a5169cA082A6c7203;
    address thirdJury = 0x5C9b7ce8b884f5D988578d3B58DcBCF8Fa15F758;
    address beneficiary = 0x10E1Be9F6A5aD767b6fbB9ab32cEA8cf208f1543;

    function testGetContractStatesAfterDeploying() public {
        uint expectedScaleMaxValue = 10;
        string memory expectedBeneficiaryName = "Anthony Zuc";

        AssertUint.equal(evaluation.scaleMaxValue(), expectedScaleMaxValue, "Compare scale max value after deploying contract");
        AssertAddress.equal(evaluation.beneficiary(), beneficiary, "Compare beneficiary address after deploying contract");
        AssertString.equal(evaluation.beneficiaryName(), expectedBeneficiaryName, "Compare beneficiary name after deploying contract");

        address fakeJury = 0x67fDea9dFACc29a20aef5Cd0B833B7d0485AeDfd;
        AssertBool.isTrue(evaluation.juries(firstJury), "Check if jury address is marked as true after deploying contract");
        AssertBool.isTrue(evaluation.juries(secondJury), "Check if jury address is marked as true after deploying contract");
        AssertBool.isTrue(evaluation.juries(thirdJury), "Check if jury address is marked as true after deploying contract");
        AssertBool.isFalse(evaluation.juries(fakeJury), "Check if fake jury address is marked as false after deploying contract");
    }

    function testEvaluate() public {
        if (evaluation.isHappened(evaluation.evaluationEnd()) ||
            !evaluation.evaluators(msg.sender)
        ) {
            return;
        }

        uint value = 9;
        bool fake = false;
        string memory secret = "s3cr37";

        bytes32 evaluationHash = keccak256(abi.encodePacked(value, fake, secret));

        payable(address(evaluation)).transfer(10);
        evaluation.evaluate(evaluationHash);

        AssertBool.equal(evaluation.evaluators(msg.sender), true, "Should be marked as true after evaluate");
    }

    function testReveal() public {
        if (!evaluation.isHappened(evaluation.evaluationEnd()) ||
            evaluation.isHappened(evaluation.revealEnd()) ||
            evaluation.evaluatorsRevealed(msg.sender)
        ) {
            return;
        }

        AssertBool.isFalse(evaluation.evaluatorsRevealed(msg.sender), "Should be marked as false before reveal");
        uint evaluationSumBeforeReveal = evaluation.evaluationSum();

        uint value = 9;
        bool fake = false;
        string memory secret = "s3cr37";
        evaluation.reveal(value, fake, secret);

        uint evaluationSumAfterReveal = evaluation.evaluationSum();

        AssertUint.isAbove(evaluationSumAfterReveal, evaluationSumBeforeReveal, "After reveal evaluation sum should be greater than until");
        AssertBool.isTrue(evaluation.evaluatorsRevealed(msg.sender), "Should be marked as true after reveal");
    }

    function testEndEvaluation() public {
        if (!evaluation.isHappened(evaluation.revealEnd()) ||
            evaluation.evaluationEnded()) {
            return;
        }

        evaluation.endEvaluation();

        AssertBool.isTrue(evaluation.evaluationEnded(), "After evaluation ending that variable should be true");

        uint expectedDepositAfterRefund = 0;

        (bytes32 firstJuryEvaluation, uint firstJuryDeposit) = evaluation.evaluations(firstJury);
        (bytes32 secondJuryEvaluation, uint secondJuryDeposit) = evaluation.evaluations(secondJury);
        (bytes32 thirdJuryEvaluation, uint thirdJuryDeposit) = evaluation.evaluations(thirdJury);

        AssertUint.equal(firstJuryDeposit, expectedDepositAfterRefund, "Must be reset to zero");
        AssertUint.equal(secondJuryDeposit, expectedDepositAfterRefund, "Must be reset to zero");
        AssertUint.equal(thirdJuryDeposit, expectedDepositAfterRefund, "Must be reset to zero");
    }
}
