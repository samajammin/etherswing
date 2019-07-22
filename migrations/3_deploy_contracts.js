const EtherSwing = artifacts.require('ether_swing');
const UniswapExchange = artifacts.require('uniswap_exchange');
const UniswapFactory = artifacts.require('uniswap_factory');

const DsToken = artifacts.require('DSToken');
const SaiTub = artifacts.require('SaiTub');

const constants = require('../utils/constants');

module.exports = async (deployer, network) => {
  if (['develop', 'development', 'test'].includes(network)) {
    /*  
    Steps for dev environment:
      - Deploy UniswapExchange (exchange template) contract
      - Deploy UniswapFactory contract
      - Initialize UniswapFactory with UniswapExchange address
      - Deploy Dai UniswapExchange contract
      - Approve Dai UniswapExchange contract to transfer Dai
      - Add liquidity to Dai UniswapExchange
      - Deploy EtherSwing
    */

    // Deploy Dai token contract
    // TODO update to use MakerDAO's Dai from previous deploy script
    // await deployer.deploy(DaiToken, name, symbol, decimals, supply);
    // const daiInstance = await DaiToken.at(DaiToken.address);

    // Deploy UniswapExchange (exchange template) contract
    await deployer.deploy(UniswapExchange);

    // Deploy & initialize UniswapFactory contract
    await deployer.deploy(UniswapFactory);
    const factoryInstance = await UniswapFactory.at(UniswapFactory.address);
    await factoryInstance.initializeFactory(UniswapExchange.address);

    // Get Dai token from MakerDAO deploy script
    const saiTub = await SaiTub.deployed();
    const dai = await DsToken.at(await saiTub.sai());
    // Deploy UniswapExchange contract for Dai token
    await factoryInstance.createExchange(dai.address);

    // Approve Dai UniswapExchange contract to transfer Dai
    const daiExchangeAddress = await factoryInstance.getExchange(dai.address);
    await dai.approve(daiExchangeAddress);

    // Add liquidity to Dai UniswapExchange (5 ETH, 10000 DAI)
    const daiExchangeInstance = await UniswapExchange.at(daiExchangeAddress);
    const minLiquidity = 0;
    const maxTokens = 10000;
    const deadline = Math.floor(Date.now() / 1000) + 300;
    await daiExchangeInstance.addLiquidity(minLiquidity, maxTokens, deadline, {
      value: 5000000000000000000
    });
    // Deploy EtherSwing
    await deployer.deploy(EtherSwing, UniswapFactory.address, {
      value: 10000000000000000000
    });
  } else if (
    ['mainnet', 'rinkeby', 'mainlocal', 'mainlocal-fork'].includes(network)
  ) {
    console.log(`Skipping Uniswap deploy for network: ${network}`);
    // TODO update to use makerTub address
    deployer.deploy(
      EtherSwing,
      constants.uniswapFactoryContracts[network],
      constants.makerDaoContracts[network].TUB
      // constants.makerDaoContracts[network].SAI
    );
  } else {
    throw new Error(`Unexpected network in deploy script: ${network}`);
  }
};
