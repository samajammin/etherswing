const EtherSwing = artifacts.require('ether_swing');
const DSToken = artifacts.require('DSToken');
const UniswapExchange = artifacts.require('uniswap_exchange');
const UniswapFactory = artifacts.require('uniswap_factory');

const constants = require('../utils/constants.js');
const { expectRevert } = require('openzeppelin-test-helpers');
const { expect } = require('chai');

// TODO how to only execute when network is 'mainlocal'?
// Can we access 'network' like in migrations?
contract('EtherSwing', accounts => {
  let daiToken;
  let uniswapExchange;
  let uniswapFactory;
  let daiExchangeAddress;
  let daiExchange;
  let etherSwing;

  const owner = accounts[0];
  const user = accounts[1];

  const pointOneEthInWei = web3.utils.toWei('0.1', 'ether');
  const oneEthInWei = web3.utils.toWei('1', 'ether');
  const fiveEthInWei = web3.utils.toWei('5', 'ether');
  const tenEthInWei = web3.utils.toWei('10', 'ether');
  const oneHundredEthInWei = web3.utils.toWei('100', 'ether');
  const thousandEthInWei = web3.utils.toWei('1000', 'ether');

  beforeEach(async () => {
    daiToken = await DSToken.at('0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359');
    uniswapFactory = await UniswapFactory.at(
      '0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95'
    );
  });

  describe.skip('DAI', async () => {
    it('should have totalSupply()', async () => {
      expect(await daiToken.totalSupply()).to.be.bignumber.equal(
        '85562923587097955945310051'
      );
    });
    it('should have symbol()', async () => {
      const symbol = await daiToken.symbol();
      const decoded = web3.utils.hexToUtf8(symbol);
      expect(decoded).equal('DAI');
    });
  });
});
