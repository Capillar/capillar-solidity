pragma solidity ^0.4.11;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/TokenCAP.sol";
import "../tools/ThrowProxy.sol";

// Standalone testing suite S01 for TokenCAP contract
contract Test_CAP
{
	TokenCAP 	inst;		// Instance of TokenCAP
	ThrowProxy 	proxyImpl;	// Proxy for TokenCAP
	TokenCAP	proxy;		// Proxy synonym

	function Test_CAP()
	{// setup
		inst = new TokenCAP();
		proxyImpl = new ThrowProxy(address(inst));
		proxy = TokenCAP(address(proxyImpl));
	}

	function testSimpleBurning() 
	{	// test S0101 - modeling burning single
		bool res;

		Assert.equal(inst.balanceOf(this), 	0, 				"S010101: Owner should have 0 balance initially");

		uint smallAmmount = 1e10;
		inst.mint(this, smallAmmount);
		Assert.equal(inst.balanceOf(this), smallAmmount, 	"S010102: Minting should increase balance");

		uint expectedSupply = inst.totalSupply() - smallAmmount;
		inst.burnBalance(this);
		Assert.equal(inst.balanceOf(this), 0, 				"S010103: Burning account should result in 0 balance");
		Assert.equal(inst.totalSupply(), expectedSupply, 	"S010104: Burning account should result in supply decrease");
		
		// using proxy to test throwing
		proxy.burnBalance(this);
		res = proxyImpl.execute.gas(1e5)();
		Assert.isFalse(res, 								"S010105: Should throw when trying to burn from not owner");

		transferOwnerToProxy();
		proxy.burnBalance(this);
		res = proxyImpl.execute.gas(1e5)();
		Assert.isFalse(res, 								"S010106: Should throw when trying to burn 0 ammount");
		transferOwnerToTest();
	}

	function transferOwnerToProxy() internal
	{// helper function transfering owner to proxy
		require(inst.owner() == address(this));
		inst.setOwner(address(proxy));
	}
	function transferOwnerToTest() internal
	{// helper function transfering owner to test contract
		require(inst.owner() == address(proxy));
		proxy.setOwner(address(this));
		proxyImpl.execute.gas(5e4)();	// set owner function shouldnt take more than 50000 gas
	}
}