pragma solidity ^0.7.0;

import "truffle/AssertAddress.sol";
import "truffle/AssertBool.sol";
import "truffle/AssertString.sol";
import "truffle/AssertUint.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/CommitRevealEvaluation.sol";
import "../contracts/abdk-libraries-solidity/ABDKMathQuad.sol";

contract TestVoting {
    CommitRevealEvaluation evaluation = CommitRevealEvaluation(
        DeployedAddresses.CommitRevealEvaluation()
    );

    function testGetContractStatesAfterDeploying() public {
        uint expectedScaleMaxValue = 10;
        address expectedBeneficiary = 0x10E1Be9F6A5aD767b6fbB9ab32cEA8cf208f1543;
        string memory expectedBeneficiaryName = "Anthony Zuc";

        AssertUint.equal(evaluation.scaleMaxValue(), expectedScaleMaxValue, "Compare scale max value after deploying contract");
        AssertAddress.equal(evaluation.beneficiary(), expectedBeneficiary, "Compare beneficiary address after deploying contract");
        AssertString.equal(evaluation.beneficiaryName(), expectedBeneficiaryName, "Compare beneficiary name after deploying contract");

        address firstJury = 0xD0D1597614662cf53C1ADA223D9268b984B68714;
        address secondJury = 0x2c61097258C54cE52143224a5169cA082A6c7203;
        address thirdJury = 0x5C9b7ce8b884f5D988578d3B58DcBCF8Fa15F758;
        address fakeJury = 0x67fDea9dFACc29a20aef5Cd0B833B7d0485AeDfd;
        AssertBool.equal(evaluation.juries(firstJury), true, "Check if jury address is marked as true after deploying contract");
        AssertBool.equal(evaluation.juries(secondJury), true, "Check if jury address is marked as true after deploying contract");
        AssertBool.equal(evaluation.juries(thirdJury), true, "Check if jury address is marked as true after deploying contract");
        AssertBool.equal(evaluation.juries(fakeJury), false, "Check if fake jury address is marked as false after deploying contract");
    }
}
