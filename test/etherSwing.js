// TODO figure out how to import...?
// import {
//   MAX_UINT
// pointOneEthInWei,
// oneEthInWei,
// tenEthInWei
// oneHundredEthInWei,
// thousandEthInWei
// } from '../utils/constants';

// const EtherSwing = artifacts.require('ether_swing');
// const Token = artifacts.require('erc20_token');
// const UniswapExchange = artifacts.require('uniswap_exchange');
// const UniswapFactory = artifacts.require('uniswap_factory');

// const { expectRevert } = require('openzeppelin-test-helpers');
// const { expect } = require('chai');

// TODO update. For now, use etherSwingMainnet

// contract('EtherSwing', accounts => {
//   let dai;
//   let uniswapExchange;
//   let uniswapFactory;
//   let daiExchangeAddress;
//   let daiExchange;
//   let etherSwing;

//   const owner = accounts[0];
//   const user = accounts[1];

//   const pointOneEthInWei = web3.utils.toWei('0.1', 'ether');
//   const oneEthInWei = web3.utils.toWei('1', 'ether');
//   const onePointOneEthInWei = web3.utils.toWei('1.1', 'ether');
//   // const fiveEthInWei = web3.utils.toWei('5', 'ether');
//   const tenEthInWei = web3.utils.toWei('10', 'ether');
//   // const oneHundredEthInWei = web3.utils.toWei('100', 'ether');
//   // const thousandEthInWei = web3.utils.toWei('1000', 'ether');

//   beforeEach(async () => {
//     // TODO use DSToken to simulate real Dai... tricky b/c supply will start at 0, need to open a CDP
//     // Deploy Dai
//     const name = 'Dai';
//     const symbol = 'DAI';
//     const decimals = 18;
//     const supply = 100000000;
//     dai = await Token.new(name, symbol, decimals, supply);

//     // Deploy Uniswap Dai exchange
//     uniswapExchange = await UniswapExchange.new();
//     uniswapFactory = await UniswapFactory.new();
//     await uniswapFactory.initializeFactory(uniswapExchange.address);
//     await uniswapFactory.createExchange(dai.address);

//     // Add liquidity
//     daiExchangeAddress = await uniswapFactory.getExchange(dai.address);
//     dai.approve(daiExchangeAddress, Number.MAX_SAFE_INTEGER);
//     daiExchange = await UniswapExchange.at(daiExchangeAddress);
//     const minLiquidity = 0;
//     const maxTokens = 10000;
//     const deadline = Math.floor(Date.now()) + 300;
//     await daiExchange.addLiquidity(minLiquidity, maxTokens, deadline, {
//       from: owner,
//       value: oneEthInWei
//     });

//     // Deploy EtherSwing
//     // TODO update to use makerTub address
//     etherSwing = await EtherSwing.new(uniswapFactory.address, dai.address, {
//       value: oneEthInWei
//     });
//   });

//   describe.skip('initial state', async () => {
//     it('should have balance', async () => {
//       expect(await etherSwing.getContractBalance()).to.be.bignumber.equal(
//         oneEthInWei
//       );
//     });

//     it('should have a dai token address', async () => {
//       expect(await etherSwing.daiAddress()).to.have.lengthOf(42);
//     });

//     it('should have a uniswap factory address', async () => {
//       expect(await etherSwing.uniswapFactoryAddress()).to.have.lengthOf(42);
//     });

//     it('should have a dai exchange address', async () => {
//       expect(await etherSwing.daiExchangeAddress()).to.have.lengthOf(42);
//     });
//   });

//   describe('fund()', async () => {
//     it('should accept funds', async () => {
//       expect(await etherSwing.getContractBalance()).to.be.bignumber.equal(
//         oneEthInWei
//       );
//       await etherSwing.fund({ from: owner, value: pointOneEthInWei });
//       expect(await etherSwing.getContractBalance()).to.be.bignumber.equal(
//         onePointOneEthInWei
//       );
//     });

//     it('should fail if no value is sent', async () => {
//       await expectRevert(
//         etherSwing.fund({ from: owner }),
//         'Must send value to call this function.'
//       );
//     });
//   });

//   describe('transfer()', async () => {
//     it('should transfer valid funds', async () => {
//       await etherSwing.fund({ from: owner, value: pointOneEthInWei });
//       expect(await etherSwing.getContractBalance()).to.be.bignumber.equal(
//         onePointOneEthInWei
//       );
//       await etherSwing.transfer(owner, pointOneEthInWei, { from: owner });
//       expect(await etherSwing.getContractBalance()).to.be.bignumber.equal(
//         oneEthInWei
//       );
//     });

//     it('should fail if not called by owner', async () => {
//       await expectRevert(
//         etherSwing.transfer(user, 300, { from: user }),
//         'Must be contract owner to call this function.'
//       );
//     });

//     it('should fail for invalid funds', async () => {
//       await etherSwing.fund({ from: owner, value: pointOneEthInWei });
//       expect(await etherSwing.getContractBalance()).to.be.bignumber.equal(
//         onePointOneEthInWei
//       );
//       await expectRevert(
//         etherSwing.transfer(owner, tenEthInWei, { from: owner }),
//         'Insufficient contract balance.'
//       );
//     });
//   });

//   describe.skip('uniswap', async () => {
//     it('should have a Dai exchange', async () => {
//       expect(await daiExchange.factoryAddress()).to.equal(
//         uniswapFactory.address
//       );

//       const ethToToken = await daiExchange.getEthToTokenInputPrice(oneEthInWei);
//       expect(ethToToken).to.be.bignumber.equal('4992');

//       const tokenToEth = await daiExchange.getTokenToEthInputPrice(4992);
//       expect(tokenToEth).to.be.bignumber.equal('332310611240257076');
//     });

//     it('exchangeEthForDai()', async () => {
//       const daiBought = await etherSwing.exchangeEthForDai(pointOneEthInWei, {
//         from: user
//       });
//       expect(daiBought).to.be.bignumber.equal('499223872'); // TODO fix... returns tx receipt
//     });

//     it('exchangeDaiForEth()', async () => {
//       let daiOwned = await dai.balanceOf(owner);
//       expect(daiOwned).to.be.bignumber.equal('99999999999999999999990000');

//       // TODO remove once contract can withdraw Dai from MakerDAO
//       await dai.transfer(etherSwing.address, 10000000, { from: owner });

//       const daiInContract = await dai.balanceOf(etherSwing.address);
//       expect(daiInContract).to.be.bignumber.equal('10000000');

//       const ethBought = await etherSwing.exchangeDaiForEth(100, {
//         from: owner
//       });
//       expect(ethBought).to.equal(10);

//       daiOwned = await dai.balanceOf(owner);
//       expect(daiOwned).to.be.bignumber.equal('99999999999999999998990000');
//     });
//   });

//   describe.skip('openPosition()', async () => {
//     it('should open leveraged position', async () => {
//       expect(
//         await etherSwing.getLockedEthBalance({ from: user })
//       ).to.be.bignumber.equal('0');
//       expect(await etherSwing.getContractBalance()).to.be.bignumber.equal(
//         oneEthInWei
//       );
//       await etherSwing.openPosition(2, { from: user, value: pointOneEthInWei });
//       expect(await etherSwing.getContractBalance()).to.be.bignumber.equal(
//         onePointOneEthInWei
//       );
//       // TODO real failure...
//       expect(
//         await etherSwing.getLockedEthBalance({ from: user })
//       ).to.be.bignumber.equal(oneEthInWei);
//     });

//     it('should fail if no value is sent', async () => {
//       await expectRevert(
//         etherSwing.openPosition(2, { from: user }),
//         'Must send value to call this function.'
//       );
//     });

//     it('should fail if insufficient contract balance', async () => {
//       await expectRevert(
//         etherSwing.openPosition(2, {
//           from: user,
//           value: tenEthInWei
//         }),
//         'Insufficient contract balance. Please use a smaller amount or try again later.'
//       );
//     });

//     it('should fail if leverage is too high', async () => {
//       await expectRevert(
//         etherSwing.openPosition(5, { from: user, value: pointOneEthInWei }),
//         'Leverage multiplier must be below 3.'
//       );
//     });
//   });
// });
