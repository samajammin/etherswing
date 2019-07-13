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
  let daiExchangeAddress;
  let daiExchange;
  let etherSwing;

  const owner = accounts[0];
  const user = accounts[1];

  const pointOneEthInWei = web3.utils.toWei('0.1', 'ether');
  const oneEthInWei = web3.utils.toWei('1', 'ether');
  const thousandEthInWei = web3.utils.toWei('1000', 'ether');

  beforeEach(async () => {
    // Deploy Uniswap Dai exchange
    daiToken = await DaiToken.new('Dai', 'DAI', 18, 100000000);
    uniswapExchange = await UniswapExchange.new();
    uniswapFactory = await UniswapFactory.new();

    await uniswapFactory.initializeFactory(uniswapExchange.address);
    await uniswapFactory.createExchange(daiToken.address);
    daiExchangeAddress = await uniswapFactory.getExchange(daiToken.address);
    daiToken.approve(daiExchangeAddress, 100000);
    daiExchange = await UniswapExchange.at(daiExchangeAddress);

    const minLiquidity = 0;
    const maxTokens = 10000;
    const deadline = Math.floor(Date.now()) + 300;
    await daiExchange.addLiquidity(minLiquidity, maxTokens, deadline, {
      from: owner,
      value: 1000000000
    });

    // Deploy EtherSwing
    etherSwing = await EtherSwing.new(
      uniswapFactory.address,
      daiToken.address,
      {
        value: 1000
      }
    );
  });

  // TODO test uniswap functionality, e.g. liquidity

  describe('initial state', async () => {
    it('should have balance', async () => {
      expect(await etherSwing.getContractBalance()).to.be.bignumber.equal(
        '1000'
      );
    });

    it('should have a dai token address', async () => {
      expect(await etherSwing.daiTokenAddress()).to.have.lengthOf(42);
    });

    it('should have a uniswap factory address', async () => {
      expect(await etherSwing.uniswapFactoryAddress()).to.have.lengthOf(42);
    });

    it('should have a dai exchange address', async () => {
      expect(await etherSwing.daiExchangeAddress()).to.have.lengthOf(42);
    });
  });

  describe('fund()', async () => {
    it('should accept funds', async () => {
      expect(await etherSwing.getContractBalance()).to.be.bignumber.equal(
        '1000'
      );
      await etherSwing.fund({ from: owner, value: 500 });
      expect(await etherSwing.getContractBalance()).to.be.bignumber.equal(
        '1500'
      );
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
      expect(await etherSwing.getContractBalance()).to.be.bignumber.equal(
        '1500'
      );
      await etherSwing.transfer(owner, 300, { from: owner });
      expect(await etherSwing.getContractBalance()).to.be.bignumber.equal(
        '1200'
      );
    });

    it('should fail if not called by owner', async () => {
      await expectRevert(
        etherSwing.transfer(user, 300, { from: user }),
        'Must be contract owner to call this function.'
      );
    });

    it('should fail for invalid funds', async () => {
      await etherSwing.fund({ from: owner, value: 500 });
      expect(await etherSwing.getContractBalance()).to.be.bignumber.equal(
        '1500'
      );
      await expectRevert(
        etherSwing.transfer(owner, 8000, { from: owner }),
        'Insufficient contract balance.'
      );
    });
  });

  describe('uniswap', async () => {
    it('should have a Dai exchange', async () => {
      expect(await daiExchange.factoryAddress()).to.eql(uniswapFactory.address);

      const ethToToken = await daiExchange.getEthToTokenInputPrice(oneEthInWei);
      expect(ethToToken).to.be.bignumber.equal('9999');

      const tokenToEth = await daiExchange.getTokenToEthInputPrice(9999);
      expect(tokenToEth).to.be.bignumber.equal('499223872');
    });

    it('can swap ETH for Dai', async () => {
      const daiReceived = await etherSwing.exchangeDai(pointOneEthInWei, {
        value: pointOneEthInWei, // TODO remove once passing 'value' works
        from: user
      });
      expect(daiReceived).to.be.bignumber.equal('499223872'); // TODO fix... returns tx promise
    });
  });

  describe('openPosition()', async () => {
    it('should open leveraged position', async () => {
      expect(
        await etherSwing.getLockedEthBalance({ from: user })
      ).to.be.bignumber.equal('0');
      expect(await etherSwing.getContractBalance()).to.be.bignumber.equal(
        '1000'
      );
      await etherSwing.openPosition(2, { from: user, value: 500 });
      expect(await etherSwing.getContractBalance()).to.be.bignumber.equal(
        '1500'
      );
      expect(
        await etherSwing.getLockedEthBalance({ from: user })
      ).to.be.bignumber.equal('1500');
    });

    it('should fail if no value is sent', async () => {
      await expectRevert(
        etherSwing.openPosition(2, { from: user }),
        'Must send value to call this function.'
      );
    });

    it('should fail if insufficient contract balance', async () => {
      await expectRevert(
        etherSwing.openPosition(2, {
          from: user,
          value: 2000
        }),
        'Insufficient contract balance. Please use a smaller amount or try again later.'
      );
    });

    it('should fail if leverage is too high', async () => {
      await expectRevert(
        etherSwing.openPosition(5, { from: user, value: 500 }),
        'Leverage multiplier must be below 3.'
      );
    });
  });
});
