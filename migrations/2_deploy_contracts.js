var VyperStorage = artifacts.require('VyperStorage');
var Counter = artifacts.require('Counter');
var EtherSwing = artifacts.require('EtherSwing');

module.exports = function(deployer) {
  deployer.deploy(VyperStorage);
  deployer.deploy(Counter);
  deployer.deploy(EtherSwing);
};
