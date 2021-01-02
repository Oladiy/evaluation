pragma solidity ^0.7.0;

import "truffle/AssertAddress.sol";
import "truffle/AssertString.sol";
import "truffle/AssertUint.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/CommitRevealEvaluation.sol";

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
    }
}
