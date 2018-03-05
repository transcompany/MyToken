var PlusPlusCrowdsale = artifacts.require("./PlusPlusCrowdsale.sol");

module.exports = function(deployer) {
  deployer.deploy(PlusPlusCrowdsale);
};
