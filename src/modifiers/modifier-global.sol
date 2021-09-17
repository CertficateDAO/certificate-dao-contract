// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.6;

import "@openzeppelin/contracts/utils/Context.sol";
import "../constants/constant-global.sol";

abstract contract GlobalAble is Context {

    bool private _stopWorld = false;

    modifier isStopWorld {
        require(!_stopWorld,"STOP WORLD");
        _;
    }

    function setStopWorld(bool boostrap_) public {
        _stopWorld = boostrap_;
    }
}