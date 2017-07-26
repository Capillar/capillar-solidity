pragma solidity ^0.4.11;

import "./external/ERC20.sol";
import "./interfaces/iTokenCAP.sol";

//================= CAP database contract =======================
contract TokenCAP is ERC20, iTokenCAP
{
	string 	public constant		symbol = "CAP";
	string 	public constant		name = "Capillar.io platform token";
	uint8 	public constant		decimals = 9;
	uint 						supply = 10e18; 	// 10 billion tokens divisible up to 9 figures - can only be changed by burning tokens
	uint 						activeCount = 0;	// ammount of tradeable tokens minted
	uint 						burnedCount = 0;  	// ammount of burned tokens

	// Balance for each account, always positive or zero
	mapping (address => uint) balances;
	// Owner of account approves the transfer of an amount to another account
	mapping (address => mapping (address => uint)) allowed;
	// Irriducible remainder for each account
	mapping (address => uint) irreducibles;

	function TokenCAP() {} // constructor
	function () payable { throw; } // fallback

	// ----------- Implementation for ERC20 functionality -------------------
	function totalSupply() constant returns(uint totalSupply) 
		{ return supply; }
	function balanceOf(address _adr) constant returns(uint balance) 
		{ return balances[_adr]; }
	function allowance(address _owner, address _spender) constant returns (uint remaining)
		{ return allowed[_owner][_spender]; }
	
	// Inherited events from ERC20
	//event Transfer( address indexed _from,   address indexed _to,		uint _value);
	//event Approval( address indexed _owner,  address indexed _spender,	uint _value);
	
	function transfer(address _to, uint _amount) returns (bool success)
	{// Transfer fund from sender account to target account
		if (_amount == 0 || balances[msg.sender] < irreducibles[msg.sender] + _amount)
			return false;
		balances[msg.sender] -= _amount;
		// do not test for overflow because supply should be limited by supply and balance is never negative
		balances[_to] += _amount;
		Transfer(msg.sender, _to, _amount);
		return true;
	}
	function transferFrom(address _from, address _to, uint _amount) returns (bool success)
	{
		if (_amount == 0 || balances[msg.sender] < irreducibles[msg.sender] + _amount  || allowed[_from][msg.sender] < _amount)
			return false;
		allowed[_from][msg.sender] -= _amount;
		balances[_from] -= _amount;
		// do not test for overflow because supply should be limited by supply and balance is never negative
		balances[_to] += _amount;
		Transfer(_from, _to, _amount);
		return true;
	}
	// Allow _spender to withdraw from your account, multiple times, up to the _value amount.
	// If this function is called again it overwrites the current allowance with _value.
	function approve(address _spender, uint _amount) returns (bool success) 
	{
		allowed[msg.sender][_spender] = _amount;
		Approval(msg.sender, _spender, _amount);
		return true;
	}

	// -------------- Interface for Controller contract -------------------
	function activeTokens() constant returns(uint amount) 
		{ return activeCount; }
	function mintedTokens() constant returns(uint amount) 
		{ return activeCount + burnedCount; }
	function burnedTokens() constant returns(uint amount) 
		{ return burnedCount; }
	function irreducibleOf(address _adr) constant returns(uint balance) 
		{ return irreducibles[_adr]; }

	event Minted(address indexed _to, uint _value);		// Tokens minted
	event Burned(uint _value);							// Tokens burned
	event Limited(address indexed _acc, uint _limit);	// Irreducible remainder changed

	function mint(address _to, uint _amount) onlyOwner returns(bool success)
	{// minting new tokens
		if(activeCount + _amount <= activeCount   	// overflow check
			|| activeCount + _amount > supply)		// minting is limited
			return false;
		balances[_to] += _amount;
		activeCount += _amount;
		Minted(_to, _amount);
		return true;
	}
	function limitAccount(address _acc, uint _limit) onlyOwner
	{// Set irreducible remainder for account
		irreducibles[_acc] = _limit;
		Limited(_acc, _limit);
	}
	function burnNotDistrTokens(uint _amount) onlyOwner returns(bool success)
	{// Burn _amount of tokens that were not yet distributed
		if(burnedCount + _amount <= burnedCount || activeCount + _amount > supply)
			return false;
		burnedCount += _amount;
		supply -= _amount;
		Burned(_amount);
		return true;
	}
	function burnBalance(address _account) onlyOwner returns(uint value)
	{// Burn balance for specific account - can be used for migrations
		value = balances[_account];
		require(value > 0);
		balances[_account] = 0;
		burnedCount += value;
		activeCount -= value;
		supply -= value;
		Burned(value);
	}
}