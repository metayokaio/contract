// SPDX-License-Identifier: MIT

pragma solidity ^0.7.0;

pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/EnumerableSet.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

/**
 *
 * Meta Yoka Coin 
 * YOC
 */
contract YOC is ERC20, Ownable {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    uint256 public constant maxSupply = 21000000 * 1e18;

    uint256 private _openTransferTimestamp = 1e18;

    EnumerableSet.AddressSet private _minters;
    mapping(address => bool) private _isExcludedFrom;

    constructor(uint256 initialSupply) public ERC20("Meta YoKa Coin", "YOC") {
        _mint(msg.sender, initialSupply);

        _isExcludedFrom[msg.sender] = true;
        _isExcludedFrom[address(this)] = true;
    }

    // mint within max supply
    function mint(address _to, uint256 _amount)
        public
        onlyMinter
        returns (bool)
    {
        if (_amount.add(totalSupply()) > maxSupply) {
            return false;
        }
        _mint(_to, _amount);
        return true;
    }

    function addMinter(address _addMinter) public onlyOwner returns (bool) {
        require(_addMinter != address(0), "addMinter invalid");
        return EnumerableSet.add(_minters, _addMinter);
    }

    function delMinter(address _delMinter) public onlyOwner returns (bool) {
        require(_delMinter != address(0), "delMinter invalid");
        return EnumerableSet.remove(_minters, _delMinter);
    }

    function getMinterLength() public view returns (uint256) {
        return EnumerableSet.length(_minters);
    }

    function isMinter(address account) public view returns (bool) {
        return EnumerableSet.contains(_minters, account);
    }

    function getMinter(uint256 _index) public view onlyOwner returns (address) {
        require(_index <= getMinterLength() - 1, "index out of bounds");
        return EnumerableSet.at(_minters, _index);
    }

    function setTransferOpenTimestamp(uint256 openTransferTimestamp)
        external
        onlyOwner
    {
        require(_openTransferTimestamp != 0, "opentime invalid");
        _openTransferTimestamp = openTransferTimestamp;
    }

    function setExcludeFromWhiteAccount(address account, bool status)
        public
        onlyOwner
    {
        _isExcludedFrom[account] = status;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {
        if (!_isExcludedFrom[sender] && !_isExcludedFrom[recipient]) {
            require(
                block.timestamp >= _openTransferTimestamp &&
                    _openTransferTimestamp > 0,
                "invalid"
            );
        }
        super._transfer(sender, recipient, amount);
    }

    // modifier for mint function
    modifier onlyMinter() {
        require(isMinter(msg.sender), "caller is not the minter");
        _;
    }
}
