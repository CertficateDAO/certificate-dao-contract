// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.0;

import "../modifiers/modifier-committee.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "../modifiers/modifier-committee.sol";

interface ICfeToken {
    function burnAccountToken(address account_, uint256 amount_) external returns (uint256);
}


contract RegisterApi is
Pausable,
CommitteeAble
{
    struct RegisterInfo {
        string name;
        string email;
        bool usable;
    }

    uint256 public fees;

    mapping(address => RegisterInfo) public registerMapping;

    address private iCfeTokenAddress;

    event Register(string name_, string email_);

    constructor(address iCfeTokenAddress_){
        iCfeTokenAddress = iCfeTokenAddress_;
    }

    function setFees(uint256 fees_) public {
        fees = fees_;
    }

    function register(string memory name_, string memory email_) OnlyCommittee whenNotPaused public {
        //1. 获取当前调用者CFE的余额
        //2. 判断余额是否满足fee
        //3. 销毁对应账户的fee数量CFE
        //4. 将其记录到registerMapping中
        require(registerMapping[msg.sender].usable == false,"This address has been registered");
        ICfeToken token = ICfeToken(iCfeTokenAddress);
        token.burnAccountToken(msg.sender, fees);
        RegisterInfo memory registerInfo = RegisterInfo(name_,email_,true);
        registerMapping[msg.sender] = registerInfo;
        emit Register(registerInfo.name,registerInfo.email);
    }
}
