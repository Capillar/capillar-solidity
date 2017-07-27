pragma solidity ^0.4.11;

import "truffle/Assert.sol";

// ========= Contract for testing throwing functions ===============
contract ThrowProxy 
{
	address public target;
	bytes data;

	function ThrowProxy(address _target) 
		{ target = _target;	}    

	//prime the data using the fallback function.
	function() { data = msg.data; }

	function execute() returns (bool) 
		{ return target.call(data); }
}