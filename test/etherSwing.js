const EtherSwing = artifacts.require('EtherSwing');
const { expectRevert } = require('openzeppelin-test-helpers');
const { expect } = require('chai');

contract('EtherSwing', accounts => {
  let etherSwing;
  const owner = accounts[0];
  const other = accounts[1];

  beforeEach(async () => {
    etherSwing = await EtherSwing.deployed();
  });

  describe('initial state', async () => {
    it('should have owner.', async () => {
      expect(await etherSwing.getOwner()).equal(owner);
    });

    it('should have no balance', async () => {
      expect(await etherSwing.getBalance()).to.be.bignumber.equal('0');
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
    // TODO reset contract between tests?
    it('should transfer valid funds', async () => {
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
      expect(await etherSwing.getBalance()).to.be.bignumber.equal('200');
      await expectRevert(
        etherSwing.transfer(owner, 800, { from: owner }),
        'Insufficient contract balance.'
      );
    });
  });
});
