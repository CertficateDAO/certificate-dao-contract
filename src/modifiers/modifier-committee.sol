// SPDX-License-Identifier: MIT
pragma solidity >= 0.8.6;
import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract CommitteeAble is Ownable {

    mapping(address => bool) private committee;

    event AddNewCommittee(address indexed allowanceAddress, address indexed newCommittee);

    /**
     * @dev Initializes the contract setting the deployer as the initial committee.
     */
    constructor() {
        _addCommittee(owner());
    }

    /**
     * @dev Returns the bool of the msg.sender.
     */
    function isCommittee() public view virtual returns (bool) {
        return committee[_msgSender()];
    }

    /**
     * @dev Throws if called by any account other than committee.
     */
    modifier OnlyCommittee() {
        require(committee[_msgSender()] || owner() == _msgSender() , "OnlyCommittee");
        _;
    }


    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `OnlyCommittee` functions anymore. Can only be called by the committee.
     *
     * NOTE: leaveCommittee will leave any address to false. For example, so the
     * last committee leave , that modifier OnlyCommittee returns false forever.
     */
    function leaveCommittee() public virtual OnlyCommittee {
        committee[_msgSender()] = false;
    }

    /**
     * @dev add newAddress to committee .
     * Can only be called by the committee.
     */
    function addNewCommittee(address newCommittee) public OnlyCommittee virtual {
        require(newCommittee != address(0), "Not Zero address");
        _addCommittee(newCommittee);
    }

    function _addCommittee(address newCommittee) private {
        committee[newCommittee] = true;
        emit AddNewCommittee(_msgSender(), newCommittee);
    }
}