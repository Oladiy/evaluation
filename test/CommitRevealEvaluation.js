const ETHUtil = require("ethereumjs-util");
const Web3 = require("web3");

const CommitRevealEvaluation = artifacts.require("CommitRevealEvaluation");
const web3 = new Web3();

contract("CommitRevealEvaluation", accounts => {
    const firstJury = "0xD0D1597614662cf53C1ADA223D9268b984B68714";
    const secondJury = "0x2c61097258C54cE52143224a5169cA082A6c7203";
    const thirdJury = "0x5C9b7ce8b884f5D988578d3B58DcBCF8Fa15F758";
    const beneficiary = "0x10E1Be9F6A5aD767b6fbB9ab32cEA8cf208f1543";

    it("Check contract states after deploying", async () => {
        const evaluation = await CommitRevealEvaluation.deployed();

        const expectedScaleMaxValue = 10;
        const expectedBeneficiaryName = "Anthony Zuc";
        const fakeJury = accounts[9];

        const beneficiaryName = await evaluation.beneficiaryName.call();
        const scaleMaxValue = await evaluation.scaleMaxValue.call();
        const beneficiaryAddress = await evaluation.beneficiary.call();
        const owner = await evaluation.owner.call();

        assert.equal(owner, accounts[0], "Compare contract owner after deploying");
        assert.equal(scaleMaxValue, expectedScaleMaxValue, "Compare scale max value after deploying contract");
        assert.equal(beneficiaryAddress, beneficiary, "Compare beneficiary address after deploying contract");
        assert.equal(beneficiaryName, expectedBeneficiaryName, "Compare beneficiary name after deploying contract");

        assert.isTrue(await evaluation.juries(firstJury), "Check if jury address is marked as true after deploying contract");
        assert.isTrue(await evaluation.juries(secondJury), "Check if jury address is marked as true after deploying contract");
        assert.isTrue(await evaluation.juries(thirdJury), "Check if jury address is marked as true after deploying contract");
        assert.isFalse(await evaluation.juries(fakeJury), "Check if fake jury address is marked as false after deploying contract");
    });

    it("Test evaluate function", async() => {
        const evaluation = await CommitRevealEvaluation.deployed();

        const isHappenedEvaluationEnd = await evaluation.isHappened.call(await evaluation.evaluationEnd.call());
        const isEvaluator = await evaluation.evaluators.call(accounts[0]);

        if (isHappenedEvaluationEnd ||
            isEvaluator
        ){
            return;
        }

        const value = 9;
        const fake = false;
        const secret = "s3cr37";

        const evaluationHash = "something";

//        await evaluation.evaluate.call(evaluationHash);

//        assert.isTrue(await evaluation.evaluators(accounts[0]), "Should be marked as true after evaluate");
    });

    it("Test end evaluation function", async() => {
        const evaluation = await CommitRevealEvaluation.deployed();

        const isHappenedRevealEnd = await evaluation.isHappened.call(await evaluation.revealEnd.call());
        const isEvaluationEnded = await evaluation.evaluationEnded.call();

        if (!isHappenedRevealEnd ||
            isEvaluationEnded
        ) {
            return;
        }

        await evaluation.endEvaluation();

        assert.isTrue(await evaluation.evaluationEnded.call(), "After evaluation ending that variable should be true");

        const expectedDepositAfterRefund = 0;

        const firstJuryDeposit = (await evaluation.evaluations(firstJury)).deposit.toNumber();
        const secondJuryDeposit = (await evaluation.evaluations(secondJury)).deposit.toNumber();
        const thirdJuryDeposit = (await evaluation.evaluations(thirdJury)).deposit.toNumber();

        assert.equal(firstJuryDeposit, expectedDepositAfterRefund, "Must be reset to zero");
        assert.equal(secondJuryDeposit, expectedDepositAfterRefund, "Must be reset to zero");
        assert.equal(thirdJuryDeposit, expectedDepositAfterRefund, "Must be reset to zero");
    });

    it("Add and then remove jury", async () => {
        const evaluation = await CommitRevealEvaluation.deployed();

        const randomJury = "0xb81Ee96348370104C0B3B815d3926B8e0A9E9F72";

        if (!(await evaluation.juries.call(randomJury))) {
            await evaluation.addJury(randomJury);
            const isJuryInList = await evaluation.juries.call(randomJury);

            assert.isTrue(isJuryInList, "Should be marked as true after add action");
        }

        await evaluation.removeJury(randomJury);
        assert.isFalse(await evaluation.juries.call(randomJury), "Should be marked as false after remove action");
    });
});