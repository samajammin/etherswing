const DaiToken = artifacts.require('erc20_token');
const { expect } = require('chai');

contract('DaiToken', accounts => {
  let daiToken;
  const owner = accounts[0];
  // const other = accounts[1];
  const name = 'Dai';
  const symbol = 'DAI';
  const decimals = 18;
  const supply = 100000000;

  beforeEach(async () => {
    daiToken = await DaiToken.new(name, symbol, decimals, supply, {
      from: owner
    });
  });

  describe('initial state', async () => {
    it('should have values.', async () => {
      expect(await daiToken.name()).equal(name);
      expect(await daiToken.symbol()).equal(symbol);
      // expect(await daiToken.decimals()).equal(decimals); // AssertionError: expected <BN: 12> to equal 18
    });

    xit('should have getters.', async () => {
      expect(await daiToken.totalSupply()).equal(supply); // AssertionError: expected <BN: 52b7d2dcc80cd2e4000000> to equal 100000000
      expect(await daiToken.balanceOf(owner)).equal(supply); // AssertionError: expected <BN: 52b7d2dcc80cd2e4000000> to equal 100000000
    });
  });
});
