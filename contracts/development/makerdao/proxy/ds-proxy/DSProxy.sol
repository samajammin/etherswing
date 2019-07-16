pragma solidity ^0.4.13;

import "./auth.sol";
import "./note.sol";
import "./DSProxyCache.sol";

// DSProxy
// Allows code execution using a persistant identity This can be very
// useful to execute a sequence of atomic actions. Since the owner of
// the proxy can be changed, this allows for dynamic ownership models
// i.e. a multisig
contract DSProxy is DSAuth, DSNote {
    DSProxyCache public cache;  // global cache for contracts

    function DSProxy(address _cacheAddr) public {
        require(setCache(_cacheAddr));
    }

    function() public payable {
    }

    // use the proxy to execute calldata _data on contract _code
//    function execute(bytes _code, bytes _data)
//    public
//    payable
//    returns (address target, bytes32 response)
//    {
//        target = cache.read(_code);
//        if (target == 0x0) {
//            // deploy contract & store its address in cache
//            target = cache.write(_code);
//        }
//
//        response = execute(target, _data);
//    }

    function execute(address _target, bytes _data)
    public
    auth
    note
    payable
    returns (bytes32 response)
    {
        require(_target != 0x0);

        // call contract in current context
        assembly {
            let succeeded := delegatecall(sub(gas, 5000), _target, add(_data, 0x20), mload(_data), 0, 32)
            response := mload(0)      // load delegatecall output
            switch iszero(succeeded)
            case 1 {
            // throw if delegatecall faciled
                revert(0, 0)
            }
        }
    }

    //set new cache
    function setCache(address _cacheAddr)
    public
    auth
    note
    returns (bool)
    {
        require(_cacheAddr != 0x0);        // invalid cache address
        cache = DSProxyCache(_cacheAddr);  // overwrite cache
        return true;
    }
}