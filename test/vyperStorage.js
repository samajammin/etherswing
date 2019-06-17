const VyperStorage = artifacts.require('VyperStorage');

contract('VyperStorage', () => {
  it('...should store the value 89.', async () => {
    const storage = await VyperStorage.deployed();

    const storedData = await storage.get();
    assert.equal(storedData, 0, 'The storage value initializes to 0.');

    await storage.set(89);

    const storedData2 = await storage.get();
    assert.equal(storedData2, 89, 'The value 89 was not stored.');
  });
});
