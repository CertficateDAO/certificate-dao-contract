// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.6;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "../modifiers/modifier-committee.sol";
import "../modifiers/modifier-global.sol";

contract CFEToken is
ERC20,
CommitteeAble,
Pausable
{
    mapping(address => uint256) private _freezeBalances;

    constructor(string memory name_, string memory symbol_, uint256 initialSupply) ERC20(name_, symbol_) payable {
        setStopWorld(true);
        _mint(_msgSender(), initialSupply);
    }

    // 只允许委员会销毁特定账户的代币
    function burn(address account_, uint256 amount_) OnlyCommittee whenNotPaused public returns (uint256) {
        _burn(account_, amount_);
        return this.balanceOf(account_);
    }

    function _availableBalanceOf(address account_) private view returns (uint256){
        assert(balanceOf(account_) >= this.freezeBalanceOf(account_));
        return balanceOf(account_) - this.freezeBalanceOf(account_);
    }

    /* 外部函数 start */

    function freezeBalanceOf(address account_) OnlyCommittee whenNotPaused external view returns (uint256) {
        return _freezeBalances[account_];
    }

    // 已投票的代币
    // 是否被调用时是合约发起的呢？
    function freezeAccountToken(address account_, uint256 amount_) OnlyCommittee whenNotPaused external returns (uint256) {

        require(balanceOf(account_) > 0, BALANCE_NOT_ZERO);
        uint256 previousFreezeToken = this.freezeBalanceOf(account_);

            // 可用余额要大于本次可以被冻结的余额
        require(_availableBalanceOf(account_) >= amount_);
        _freezeBalances[account_] = previousFreezeToken + amount_;

            // 验证
        assert(previousFreezeToken + amount_ <= this.freezeBalanceOf(account_));
        return balanceOf(account_) - this.freezeBalanceOf(account_);
    }

    function availableBalanceOf(address account_) OnlyCommittee whenNotPaused external view returns (uint256)  {
        require(account_ != address(0), NOT_ZERO_ADDRESS);
        return _availableBalanceOf(account_);
    }

    function burnAccountToken(address account_,uint256 amount_) whenNotPaused external returns (uint256){

        require(account_ != address(0), NOT_ZERO_ADDRESS);
        _burn(account_,amount_);
        return balanceOf(account_);
    }

    /* 外部函数 end */
}
