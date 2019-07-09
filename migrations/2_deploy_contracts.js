const EtherSwing = artifacts.require('ether_swing');
const DaiToken = artifacts.require('erc20_token');
const UniswapExchange = artifacts.require('uniswap_exchange');
const UniswapFactory = artifacts.require('uniswap_factory');

module.exports = (deployer, network) => {
  const uniswapFactoryAddresses = {
    mainnet: '0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95',
    rinkeby: '0xf5D915570BC477f9B8D6C0E980aA81757A3AaC36'
  };
  // TODO add correct addresses
  const daiTokenAddresses = {
    mainnet: '0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359',
    rinkeby: '0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359'
  };

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
  if (network === 'develop') {
    let daiTokenInstance;
    let exchangeTemplateInstance;
    let factoryInstance;
    let daiExchangeAddress;
    let daiExchangeInstance;

    deployer
      // Deploy Dai token contract
      .deploy(DaiToken, 'Dai', 'DAI', 18, 10000)
      .then(instance => (daiTokenInstance = instance))
      // Deploy UniswapExchange (exchange template) contract
      .then(() => deployer.deploy(UniswapExchange))
      .then(instance => (exchangeTemplateInstance = instance))
      // Deploy & initialize UniswapFactory contract
      .then(() => deployer.deploy(UniswapFactory))
      .then(instance => {
        factoryInstance = instance;
        return factoryInstance.initializeFactory(
          exchangeTemplateInstance.address
        );
      })
      // Deploy UniswapExchange contract for Dai token
      .then(() => factoryInstance.createExchange(daiTokenInstance.address))
      // Approve Dai UniswapExchange contract to transfer Dai
      .then(() => factoryInstance.getExchange(DaiToken.address))
      .then(res => (daiExchangeAddress = res))
      .then(() => {
        daiTokenInstance.approve(daiExchangeAddress, 100000);
      })
      // Add liquidity to Dai UniswapExchange (5 ETH, 10000 DAI)
      .then(() => UniswapExchange.at(daiExchangeAddress))
      .then(instance => {
        daiExchangeInstance = instance;
        const minLiquidity = 0;
        const maxTokens = 10000;
        const deadline = Math.floor(Date.now() / 1000) + 300;
        daiExchangeInstance.addLiquidity(minLiquidity, maxTokens, deadline, {
          value: 5000000000000000000
        });
      })
      // Deploy EtherSwing
      .then(() =>
        deployer.deploy(EtherSwing, UniswapFactory.address, DaiToken.address, {
          value: 10000000000000000000
        })
      )
      .catch(err => console.log(err));
  } else if (network === 'mainnet' || network === 'rinkeby') {
    // if mainnet or rinkeby, only deploy EtherSwing
    deployer.deploy(
      EtherSwing,
      uniswapFactoryAddresses[network],
      daiTokenAddresses[network]
    );
  } else {
    throw new Error(`Unexpected network: ${network}`);
  }
};
