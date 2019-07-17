const EtherSwing = artifacts.require('ether_swing');
const DaiToken = artifacts.require('erc20_token');
const UniswapExchange = artifacts.require('uniswap_exchange');
const UniswapFactory = artifacts.require('uniswap_factory');
const constants = require('../utils/constants');

module.exports = async (deployer, network) => {
  if (['develop', 'development', 'test'].includes(network)) {
    /*  
    Steps for dev environment:
      - Deploy Dai token contract
      - Deploy UniswapExchange (exchange template) contract
      - Deploy UniswapFactory contract
      - Initialize UniswapFactory with UniswapExchange address
      - Deploy Dai UniswapExchange contract
      - Approve Dai UniswapExchange contract to transfer Dai
      - Add liquidity to Dai UniswapExchange
      - Deploy EtherSwing
    */

    const name = 'Dai';
    const symbol = 'DAI';
    const decimals = 18;
    const supply = 100000000;

    // Deploy Dai token contract
    // TODO update to use MakerDAO's Dai from previous deploy script
    // TODO delete erc20_token.vy & artifact
    await deployer.deploy(DaiToken, name, symbol, decimals, supply);
    const daiTokenInstance = await DaiToken.at(DaiToken.address);

    // Deploy UniswapExchange (exchange template) contract
    await deployer.deploy(UniswapExchange);

    // Deploy & initialize UniswapFactory contract
    await deployer.deploy(UniswapFactory);
    const factoryInstance = await UniswapFactory.at(UniswapFactory.address);
    await factoryInstance.initializeFactory(UniswapExchange.address);

    // Deploy UniswapExchange contract for Dai token
    await factoryInstance.createExchange(DaiToken.address);

    // Approve Dai UniswapExchange contract to transfer Dai
    const daiExchangeAddress = await factoryInstance.getExchange(
      DaiToken.address
    );
    await daiTokenInstance.approve(daiExchangeAddress, 100000);

    // Add liquidity to Dai UniswapExchange (5 ETH, 10000 DAI)
    const daiExchangeInstance = await UniswapExchange.at(daiExchangeAddress);
    const minLiquidity = 0;
    const maxTokens = 10000;
    const deadline = Math.floor(Date.now() / 1000) + 300;
    await daiExchangeInstance.addLiquidity(minLiquidity, maxTokens, deadline, {
      value: 5000000000000000000
    });
    // Deploy EtherSwing
    await deployer.deploy(
      EtherSwing,
      UniswapFactory.address,
      DaiToken.address,
      {
        value: 10000000000000000000
      }
    );
  } else if (
    ['mainnet', 'rinkeby', 'mainlocal', 'mainlocal-fork'].includes(network)
  ) {
    console.log(`Skipping Uniswap deploy for network: ${network}`);
    deployer.deploy(
      EtherSwing,
      constants.uniswapFactoryAddresses[network],
      constants.daiTokenAddresses[network]
    );
  } else {
    throw new Error(`Unexpected network in deploy script: ${network}`);
  }
};
