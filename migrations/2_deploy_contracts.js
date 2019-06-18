var EtherSwing = artifacts.require('EtherSwing');

// Steps for dev:
// 1. Deploy Factory contract
// 2. Deploy EtherSwing w/factory address
// 3. Deploy fake ERC20 contract
// 4. Deploy Exchange contract w/ fake ERC20 contract

module.exports = (deployer, network) => {
  // TODO: "truffle migrate" will break, must deploy Uniswap contracts first
  const uniswapFactoryAddresses = {
    mainnet: '0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95',
    rinkeby: '0xf5D915570BC477f9B8D6C0E980aA81757A3AaC36'
  };
  // TODO add correct addresses
  const daiTokenAddresses = {
    mainnet: '0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359',
    rinkeby: '0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359'
  };
  const deployNetwork = network === 'mainnet' ? 'mainnet' : 'rinkeby';
  deployer.deploy(
    EtherSwing,
    uniswapFactoryAddresses[deployNetwork],
    daiTokenAddresses[deployNetwork]
  );
  // if (network !== 'mainnet') {
  //   const DaiToken = artifacts.require('./DaiToken');
  //   deployer.deploy(DaiToken);
  // }
  // // If not mainnet or rinkeby, deploy mock Uniswap contracts
  // if (!(network in uniswapFactoryAddresses)) {
  //   const UniswapExchange = artifacts.require('./uniswap_exchange');
  //   const UniswapFactory = artifacts.require('./uniswap_factory');
  //   let exchangeTemplate;
  //   deployer
  //     .deploy(UniswapExchange)
  //     .then(instance => (exchangeTemplate = instance))
  //     .then(() => deployer.deploy(UniswapFactory))
  //     .then(instance => instance.initializeFactory(exchangeTemplate.address))
  //     .then(() =>
  //       deployer.deploy(EtherSwing, UniswapFactory.address, {
  //         value: 1000000000000000000
  //       })
  //     );
  // } else {
  //   deployer.deploy(EtherSwing, uniswapFactoryAddresses[network], {
  //     value: 1000000000000000000
  //   });
  // }
};
