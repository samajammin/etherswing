pragma solidity ^0.4.23;

contract TokenInterface {
    function approve(address, uint) public;
    function transfer(address, uint) public returns (bool);
    function deposit() public payable;
    function withdraw(uint) public;
}

contract TokenProxy {
    function transfer(address token, address guy, uint wad) public {
        require(TokenInterface(token).transfer(guy, wad));
    }

    function approve(address token, address guy, uint wad) public {
        TokenInterface(token).approve(guy, wad);
    }

    function deposit(address token) public payable {
        TokenInterface(token).deposit.value(msg.value)();
    }

    function withdraw(address token, uint wad) public {
        TokenInterface(token).withdraw(wad);
    }
}