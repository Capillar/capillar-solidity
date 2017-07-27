pragma solidity ^0.4.11;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/TokenCAP.sol";
import "../tools/ThrowProxy.sol";

// Standalone testing for TokenCAP contract
contract Test_CAP
{
	TokenCAP inst;
	ThrowProxy proxy;
	function Test_CAP()
	{// setup
		inst = new TokenCAP();
		proxy = new ThrowProxy(address(inst));
	}
	function testSimpleBurning() 
	{
		
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
		TokenCAP(address(proxy)).burnBalance(this);
		res = proxy.execute.gas(100000)();
		Assert.isFalse(res, 								"S010105: Should throw when trying to burn from not owner");

		inst.setOwner(proxy);
		TokenCAP(address(proxy)).burnBalance(this);
		res = proxy.execute.gas(100000)();
		Assert.isFalse(res, 								"S010106: Should throw when trying to burn 0 ammount");
	}
	// function testInitialBalanceWithNewMetaCoin() 
	// {

	// 	//Assert.equal(meta.getBalance(tx.origin), expected, "Owner should have 10000 MetaCoin initially");
	// }
}