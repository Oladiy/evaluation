const CommitRevealEvaluation = artifacts.require("CommitRevealEvaluation");
const ABDKMathQuad = artifacts.require("ABDKMathQuad");

module.exports = function (deployer) {
    deployer.deploy(CommitRevealEvaluation,
        100, 300, 10,
        "0x10E1Be9F6A5aD767b6fbB9ab32cEA8cf208f1543",
        "Anthony Zuc",
        [
            "0xD0D1597614662cf53C1ADA223D9268b984B68714",
            "0x2c61097258C54cE52143224a5169cA082A6c7203",
            "0x5C9b7ce8b884f5D988578d3B58DcBCF8Fa15F758",
            "0x60Cef479Df28Ca8a4165E70e061d48f3C927D81C",
        ]);
    deployer.deploy(ABDKMathQuad);
};
