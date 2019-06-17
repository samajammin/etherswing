const EtherSwing = artifacts.require('EtherSwing');

contract('EtherSwing', accounts => {
  let etherSwing;
  const owner = accounts[0];

  beforeEach(async () => {
    etherSwing = await EtherSwing.deployed();
  });

  it('should have owner.', async () => {
    assert.equal(
      await etherSwing.getOwner(),
      owner,
      'contract deployer should be owner.'
    );
  });
});
