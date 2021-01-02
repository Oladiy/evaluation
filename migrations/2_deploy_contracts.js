const CommitRevealEvaluation = artifacts.require("CommitRevealEvaluation");

module.exports = function (deployer) {
    deployer.deploy(CommitRevealEvaluation, 10, 20, 10, 0x10E1Be9F6A5aD767b6fbB9ab32cEA8cf208f1543, "Anthony Zuc");
};
