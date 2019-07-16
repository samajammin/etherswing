pragma solidity ^0.4.23;

import "./ds-math/math.sol";

contract TubInterface {
    function open() public returns (bytes32);
    function join(uint) public;
    function exit(uint) public;
    function lock(bytes32, uint) public;
    function free(bytes32, uint) public;
    function draw(bytes32, uint) public;
    function wipe(bytes32, uint) public;
    function give(bytes32, address) public;
    function shut(bytes32) public;
    function cups(bytes32) public view returns (address, uint, uint, uint);
    function gem() public view returns (TokenInterface);
    function gov() public view returns (TokenInterface);
    function skr() public view returns (TokenInterface);
    function sai() public view returns (TokenInterface);
    function mat() public view returns (uint);
    function ink(bytes32) public view returns (uint);
    function tab(bytes32) public view returns (uint);
    function rap(bytes32) public view returns (uint);
    function per() public view returns (uint);
    function pep() public view returns (PepInterface);

    function ask(uint) public view returns (uint);
    function cap() public view returns (uint);
}

contract TokenInterface {
    function allowance(address, address) public view returns (uint);
    function balanceOf(address) public view returns (uint);
    function approve(address, uint) public;
    function transfer(address, uint) public returns (bool);
    function transferFrom(address, address, uint) public returns (bool);
    function deposit() public payable;
    function withdraw(uint) public;

    function totalSupply() public returns (uint);
}

contract PepInterface {
    function peek() public returns (bytes32, bool);
}

contract OtcInterface {
    function getPayAmount(address, address, uint) public view returns (uint);
    function buyAllAmount(address, uint, address pay_gem, uint) public returns (uint);
}

contract SaiProxy is DSMath {
    function open(address tub_) public returns (bytes32) {
        return TubInterface(tub_).open();
    }

    function give(address tub_, bytes32 cup, address lad) public {
        TubInterface(tub_).give(cup, lad);
    }

    function lock(address tub_, bytes32 cup) public payable {
        if (msg.value > 0) {
            TubInterface tub = TubInterface(tub_);

            (address lad,,,) = tub.cups(cup);
            require(lad == address(this), "cup-not-owned");

            tub.gem().deposit.value(msg.value)();

            uint ink = rdiv(msg.value, tub.per());
            ink = rmul(ink, tub.per()) <= msg.value ? ink : ink - 1;

            if (tub.gem().allowance(this, tub) != uint(-1)) {
                tub.gem().approve(tub, uint(-1));
            }
            tub.join(ink);

            if (tub.skr().allowance(this, tub) != uint(-1)) {
                tub.skr().approve(tub, uint(-1));
            }
            tub.lock(cup, ink);
        }
    }

    function draw(address tub_, bytes32 cup, uint wad) public {
        if (wad > 0) {
            TubInterface tub = TubInterface(tub_);
            tub.draw(cup, wad);
            tub.sai().transfer(msg.sender, wad);
        }
    }

    function handleGovFee(TubInterface tub, uint saiDebtFee, address otc_) internal {
        bytes32 val;
        bool ok;
        (val, ok) = tub.pep().peek();
        if (ok && val != 0) {
            uint govAmt = wdiv(saiDebtFee, uint(val));
            if (otc_ != address(0)) {
                uint saiGovAmt = OtcInterface(otc_).getPayAmount(tub.sai(), tub.gov(), govAmt);
                if (tub.sai().allowance(this, otc_) != uint(-1)) {
                    tub.sai().approve(otc_, uint(-1));
                }
                tub.sai().transferFrom(msg.sender, this, saiGovAmt);
                OtcInterface(otc_).buyAllAmount(tub.gov(), govAmt, tub.sai(), saiGovAmt);
            } else {
                tub.gov().transferFrom(msg.sender, this, govAmt);
            }
        }
    }

    function wipe(address tub_, bytes32 cup, uint wad, address otc_) public {
        if (wad > 0) {
            TubInterface tub = TubInterface(tub_);

            tub.sai().transferFrom(msg.sender, this, wad);
            handleGovFee(tub, rmul(wad, rdiv(tub.rap(cup), tub.tab(cup))), otc_);

            if (tub.sai().allowance(this, tub) != uint(-1)) {
                tub.sai().approve(tub, uint(-1));
            }
            if (tub.gov().allowance(this, tub) != uint(-1)) {
                tub.gov().approve(tub, uint(-1));
            }
            tub.wipe(cup, wad);
        }
    }

    function wipe(address tub_, bytes32 cup, uint wad) public {
        wipe(tub_, cup, wad, address(0));
    }

    function free(address tub_, bytes32 cup, uint jam) public {
        if (jam > 0) {
            TubInterface tub = TubInterface(tub_);
            uint ink = rdiv(jam, tub.per());
            ink = rmul(ink, tub.per()) <= jam ? ink : ink - 1;
            tub.free(cup, ink);
            if (tub.skr().allowance(this, tub) != uint(-1)) {
                tub.skr().approve(tub, uint(-1));
            }
            tub.exit(ink);
            uint freeJam = tub.gem().balanceOf(this); // Withdraw possible previous stuck WETH as well
            tub.gem().withdraw(freeJam);
            address(msg.sender).transfer(freeJam);
        }
    }

    function lockAndDraw(address tub_, bytes32 cup, uint wad) public payable {
        lock(tub_, cup);
        draw(tub_, cup, wad);
    }

    function lockAndDraw(address tub_, uint wad) public payable returns (bytes32 cup) {
        cup = open(tub_);
        lockAndDraw(tub_, cup, wad);
    }

    function wipeAndFree(address tub_, bytes32 cup, uint jam, uint wad) public payable {
        wipe(tub_, cup, wad);
        free(tub_, cup, jam);
    }

    function wipeAndFree(address tub_, bytes32 cup, uint jam, uint wad, address otc_) public payable {
        wipe(tub_, cup, wad, otc_);
        free(tub_, cup, jam);
    }

    function shut(address tub_, bytes32 cup) public {
        TubInterface tub = TubInterface(tub_);
        wipeAndFree(tub_, cup, rmul(tub.ink(cup), tub.per()), tub.tab(cup));
        tub.shut(cup);
    }

    function shut(address tub_, bytes32 cup, address otc_) public {
        TubInterface tub = TubInterface(tub_);
        wipeAndFree(tub_, cup, rmul(tub.ink(cup), tub.per()), tub.tab(cup), otc_);
        tub.shut(cup);
    }
}
