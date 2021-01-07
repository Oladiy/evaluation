const CommitRevealEvaluation = artifacts.require("CommitRevealEvaluation");

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

        // transfer
        //await evaluation.evaluate.call(evaluationHash);

        //assert.isTrue(await evaluation.evaluators(accounts[0]), "Should be marked as true after evaluate");
    });

    it("Add and then remove jury", async () => {
        const evaluation = await CommitRevealEvaluation.deployed();

        const randomJury = "0xb81Ee96348370104C0B3B815d3926B8e0A9E9F72";

        if (!(await evaluation.juries.call(randomJury))) {
            await evaluation.addJury.call(randomJury);
            const isJuryInList = await evaluation.juries.call(randomJury);

            assert.isTrue(isJuryInList, "Should be marked as true after add action");
        }

        await evaluation.removeJury.call(randomJury);
        assert.isFalse(await evaluation.juries.call(randomJury), "Should be marked as false after remove action");
    });
});