const DSToken = artifacts.require('DSToken');
const SaiTub = artifacts.require('SaiTub');

const EtherSwing = artifacts.require('ether_swing');
const UniswapExchange = artifacts.require('uniswap_exchange');
const UniswapFactory = artifacts.require('uniswap_factory');

const constants = require('../utils/constants.js');
const { expectRevert } = require('openzeppelin-test-helpers');
const { expect } = require('chai');

// TODO how to only execute when network is 'mainlocal'?
// Can we access 'network' like in migrations?
contract('EtherSwing', accounts => {
  let dai;
  let makerTub;
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
    dai = await DSToken.at(constants.makerDaoContracts.mainnet.SAI);
    uniswapFactory = await UniswapFactory.at(
      constants.uniswapFactoryContracts.mainnet
    );
    makerTub = await SaiTub.at(constants.makerDaoContracts.mainnet.TUB);
    etherSwing = await EtherSwing.new(
      uniswapFactory.address,
      makerTub.address,
      // dai.address,
      {
        value: oneEthInWei
      }
    );
  });

  describe('MakerDAO', async () => {
    it('Tub should have access to Dai', async () => {
      const daiAddress = await makerTub.sai();
      expect(daiAddress.toLowerCase()).to.eq(
        constants.makerDaoContracts.mainnet.SAI
      );
    });

    it('Dai should have totalSupply()', async () => {
      expect(await dai.totalSupply()).to.be.bignumber.equal(
        '85562923587097955945310051'
      );
    });

    it('Dai should have symbol()', async () => {
      const symbol = await dai.symbol();
      const decoded = web3.utils.hexToUtf8(symbol);
      expect(decoded).equal('DAI');
    });
  });

  describe('Uniswap', async () => {
    it('should have a Dai exchange', async () => {
      const daiExchangeAddress = await uniswapFactory.getExchange(dai.address);
      const daiExchange = await UniswapExchange.at(daiExchangeAddress);
      const daiAddress = await daiExchange.tokenAddress();
      expect(daiAddress.toLowerCase()).to.eq(
        constants.makerDaoContracts.mainnet.SAI
      );
    });
  });

  describe('EtherSwing', async () => {
    it('should have access to daiExchange', async () => {
      expect(await etherSwing.daiExchange()).to.eq(
        '0x09cabEC1eAd1c0Ba254B09efb3EE13841712bE14'
      );
    });

    it('should have access to mkrExchange', async () => {
      expect(await etherSwing.mkrExchange()).to.eq(
        '0x2C4Bd064b998838076fa341A83d007FC2FA50957'
      );
    });

    it('should have access to makerTub', async () => {
      expect(await etherSwing.makerTub()).to.eq(
        '0x448a5065aeBB8E423F0896E6c5D525C040f59af3'
      );
    });

    xit('openPosition()', async () => {
      // TODO
    });

    xit('closePosition()', async () => {
      // TODO
    });
  });
});
