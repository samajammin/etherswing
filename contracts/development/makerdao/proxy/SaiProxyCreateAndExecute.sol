pragma solidity ^0.4.23;

import "./SaiProxy.sol";

contract ProxyRegistryInterface {
    function build(address) public returns (address);
}

contract SaiProxyCreateAndExecute is SaiProxy {

    // Create a DSProxy instance and open a cup
    function createAndOpen(address registry_, address tub_) public returns (address proxy, bytes32 cup) {
        proxy = ProxyRegistryInterface(registry_).build(msg.sender);
        cup = open(tub_);
        TubInterface(tub_).give(cup, proxy);
    }

    // Create a DSProxy instance, open a cup, and lock collateral
    function createOpenAndLock(address registry_, address tub_) public payable returns (address proxy, bytes32 cup) {
        proxy = ProxyRegistryInterface(registry_).build(msg.sender);
        cup = open(tub_);
        lock(tub_, cup);
        TubInterface(tub_).give(cup, proxy);
    }

    // Create a DSProxy instance, open a cup, lock collateral, and draw DAI
    function createOpenLockAndDraw(address registry_, address tub_, uint wad) public payable returns (address proxy, bytes32 cup) {
        proxy = ProxyRegistryInterface(registry_).build(msg.sender);
        cup = open(tub_);
        lockAndDraw(tub_, cup, wad);
        TubInterface(tub_).give(cup, proxy);
    }
}
