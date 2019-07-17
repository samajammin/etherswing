// const MAX_UINT = 2 ** 256 - 1;
// TODO "ReferenceError: web3 is not defined"
// const pointOneEthInWei = web3.utils.toWei('0.1', 'ether');
// const oneEthInWei = web3.utils.toWei('1', 'ether');
// const tenEthInWei = web3.utils.toWei('10', 'ether');
// const oneHundredEthInWei = web3.utils.toWei('100', 'ether');
// const oneThousandEthInWei = web3.utils.toWei('1000', 'ether');
const uniswapFactoryAddresses = {
  mainnet: '0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95',
  mainlocal: '0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95',
  'mainlocal-fork': '0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95',
  rinkeby: '0xf5D915570BC477f9B8D6C0E980aA81757A3AaC36'
};
const daiTokenAddresses = {
  mainnet: '0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359',
  mainlocal: '0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359',
  'mainlocal-fork': '0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359',
  rinkeby: '0x8f2e097e79b1c51be9cba42658862f0192c3e487'
};
const makerDaoContracts = {
  ETH_FROM: '0x16fb96a5fa0427af0c8f7cf1eb4870231c8154b6',
  GEM: '0x7ba25f791fa76c3ef40ac98ed42634a8bc24c238',
  GOV: '0x1c3ac7216250edc5b9daa5598da0579688b9dbd5',
  PIP: '0xb7092ee7a8c4c85431962662310bbdcd4fd519e9',
  PEP: '0xc0ee05307ae4a5316f34874a3525d10c94b3c217',
  PIT: '0x0000000000000000000000000000000000000123',
  ADM: '0x4986c24c7f752c2ac2d738f1270639dd9e9d7bf5',
  SAI: '0xc226f3cd13d508bc319f4f4290172748199d6612',
  SIN: '0xe9e2b40d676fc998ede8c676d9f529ccbbc13740',
  SKR: '0xa6164a2e88e258a663772ed4912a0865af8f6d06',
  DAD: '0x7b61731911e46da837e3dcd2d8797de684c8ced1',
  MOM: '0x603d52d6ae2b98a49f8f32817ad4effe7e8a2502',
  VOX: '0xe16bf7aafeb33cc921d6d311e0ff33c4faa836dd',
  TUB: '0xe82ce3d6bf40f2f9414c8d01a35e3d9eb16a1761',
  TAP: '0x6896659267c3c9fd055d764327199a98e571e00d',
  TOP: '0x2774031b3898fbe414f929b3223ce1039325e7dc',
  MAKER_OTC: '0x06ef37a95603cb52e2dff4c2b177c84cdb3ce989',
  PROXY_REGISTRY: '0x23f67a19dc232835eaeda2075728f8295f54dfca',
  DS_PROXY: '0x570074ccb147ea3de2e23fb038d4d78324278886',
  SAI_PROXY: '0x2348a875b1631307577be0935f289e0fb9316169',
  OASIS_PROXY: '0xc72b03c37735cf122c27dc352e5f25f75beea389'
};

module.exports = {
  // pointOneEthInWei,
  // oneEthInWei,
  // tenEthInWei,
  // oneHundredEthInWei,
  // oneThousandEthInWei,
  uniswapFactoryAddresses,
  daiTokenAddresses,
  makerDaoContracts
};
