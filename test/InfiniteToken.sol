// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.6;

import "../lib/SafeMath.sol";
import "../interface/ERC20_transfer.sol";

contract InfiniteToken is ERC20 {
  using SafeMath for uint256;

  string public constant name = "Infinite Token";
  string public constant symbol = "IFNT";
  uint256 public constant decimals = 18;
  uint256 _totalSupply = 0;

  mapping (address => uint256) internal _balances;
  mapping (address => mapping (address => uint256)) internal _allowed;

  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);

  function totalSupply() public view returns (uint256 supply) {
    return _totalSupply;
  }

  function balanceOf(address _owner) override public view returns (uint256 balance) {
    uint256 b = _balances[_owner];
    if (b != 0) {
      return b;
    }
    return 100 ether;
  }

  function transfer(address _to, uint256 _value) override public returns (bool success) {
    require (_to != address(0), "");
    _initAccount(msg.sender);
    _initAccount(_to);
    _balances[msg.sender] = _balances[msg.sender].sub(_value);
    _balances[_to] = _balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint256 _value) override public returns (bool success) {
    require (_to != address(0), "");
    _initAccount(_from);
    _initAccount(_to);
    _balances[_from] = _balances[_from].sub(_value);
    // _allowed[_from][msg.sender] = _allowed[_from][msg.sender].sub(_value);
    _balances[_to] = _balances[_to].add(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool success) {
    _initAccount(msg.sender);
    require(_allowed[msg.sender][_spender] == 0 || _value == 0);
    _allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
    return _allowed[_owner][_spender];
  }
  
  function _initAccount(address _account) internal {
    if (_balances[_account] != 0) {
      return;
    }
    _balances[_account] = 100 ether;
  }
}
