const EtherSwing = artifacts.require('ether_swing');
const DaiToken = artifacts.require('erc20_token');
const UniswapExchange = artifacts.require('uniswap_exchange');
const UniswapFactory = artifacts.require('uniswap_factory');

const { expectRevert } = require('openzeppelin-test-helpers');
const { expect } = require('chai');

contract('EtherSwing', accounts => {
  let daiToken;
  let uniswapExchange;
  let uniswapFactory;
  let etherSwing;

  const owner = accounts[0];
  const other = accounts[1];

  beforeEach(async () => {
    daiToken = await DaiToken.new('Dai', 'DAI', 18, 100000000);
    uniswapExchange = await UniswapExchange.new();
    uniswapFactory = await UniswapFactory.new();

    await uniswapFactory.initializeFactory(uniswapExchange.address);
    await uniswapFactory.createExchange(daiToken.address);

    etherSwing = await EtherSwing.new(uniswapFactory.address, daiToken.address);
  });

  describe('initial state', async () => {
    it('should have no balance', async () => {
      expect(await etherSwing.getBalance()).to.be.bignumber.equal('0');
    });

    it('should have a dai token address', async () => {
      expect(await etherSwing.daiTokenAddress()).to.have.lengthOf(42);
    });

    it('should have a uniswap factory address', async () => {
      expect(await etherSwing.uniswapFactoryAddress()).to.have.lengthOf(42);
    });

    it('should have a dai exchange address', async () => {
      expect(await etherSwing.uniswapDaiExchangeAddress()).to.have.lengthOf(42);
    });
  });

  describe('fund()', async () => {
    it('should accept funds', async () => {
      expect(await etherSwing.getBalance()).to.be.bignumber.equal('0');
      await etherSwing.fund({ from: owner, value: 500 });
      expect(await etherSwing.getBalance()).to.be.bignumber.equal('500');
    });

    it('should fail if no value is sent', async () => {
      await expectRevert(
        etherSwing.fund({ from: owner }),
        'Must send value to call this function.'
      );
    });
  });

  describe('transfer()', async () => {
    it('should transfer valid funds', async () => {
      await etherSwing.fund({ from: owner, value: 500 });
      expect(await etherSwing.getBalance()).to.be.bignumber.equal('500');
      await etherSwing.transfer(owner, 300, { from: owner });
      expect(await etherSwing.getBalance()).to.be.bignumber.equal('200');
    });

    it('should fail if not called by owner', async () => {
      await expectRevert(
        etherSwing.transfer(other, 300, { from: other }),
        'Must be contract owner to call this function.'
      );
    });

    it('should fail for invalid funds', async () => {
      await etherSwing.fund({ from: owner, value: 500 });
      expect(await etherSwing.getBalance()).to.be.bignumber.equal('500');
      await expectRevert(
        etherSwing.transfer(owner, 800, { from: owner }),
        'Insufficient contract balance.'
      );
    });
  });
});
