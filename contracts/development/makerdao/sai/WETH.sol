pragma solidity ^0.4.23;

import "./ds-token/token.sol";

contract WETH is DSToken {
    function WETH() DSToken("WETH") public {}

    function deposit() public payable {
        _balances[msg.sender] = add(_balances[msg.sender], msg.value);
        _supply = add(_supply, msg.value);
    }

    function withdraw(uint amount) public {
        _balances[msg.sender] = sub(_balances[msg.sender], amount);
        _supply = sub(_supply, amount);
        require(msg.sender.call.value(amount)());
    }
}
