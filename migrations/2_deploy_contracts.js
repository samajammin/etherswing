var VyperStorage = artifacts.require('VyperStorage');
var Counter = artifacts.require('Counter');

module.exports = function(deployer) {
  deployer.deploy(VyperStorage);
  deployer.deploy(Counter);
};
