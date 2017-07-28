pragma solidity ^0.4.13;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/TokenCAP.sol";
import "../tools/ThrowProxy.sol";

// Testing suite S01 for TokenCAP contract
contract Test_CAP
{
	TokenCAP 	inst;		// Instance of TokenCAP
	ThrowProxy 	proxyImpl;	// Proxy for TokenCAP
	TokenCAP	proxy;		// Proxy synonym
	ProxyUser	user1;		// Proxy users
	ProxyUser	user2;		

	function beforeEach()
	{// setup
		inst = new TokenCAP();
		proxyImpl = new ThrowProxy(address(inst));
		proxy = TokenCAP(address(proxyImpl));
		user1 = new ProxyUser(inst);
		user2 = new ProxyUser(inst);
	}

	function testMinting()
	{// test S0101 - modeling minting tokens
		Assert.equal(inst.balanceOf(this), 	0, 					"S010101: Owner should have 0 balance initially");

		uint smallAmmount = 1e10;
		inst.mint(user1, smallAmmount);
		Assert.equal(inst.balanceOf(user1), smallAmmount, 		"S010102: Minting should increase balance");
		Assert.equal(inst.mintedTokens(), 	smallAmmount, 		"S010103: Minting should increase mintedTokens");
		Assert.equal(inst.activeTokens(), 	smallAmmount, 		"S010104: Minting should increase activeTokens");

		inst.mint(user1, smallAmmount);
		Assert.equal(inst.balanceOf(user1), 2*smallAmmount, 	"S010105: Minting should be additive");

		Assert.isFalse(inst.mint(this, uint(-1)), 				"S010106: Shouldnt mint if overflow");
		Assert.isFalse(inst.mint(this, inst.totalSupply()), 	"S010107: Shouldnt mint if supply isnt enough");

		uint leftOver = inst.totalSupply() - inst.activeTokens();
		inst.mint(this, leftOver);
		Assert.equal(inst.balanceOf(this), leftOver, 			"S010108: Minting can create full supply and can mint to owner");

		Assert.isFalse(inst.mint(this, 1), 						"S010109: Shouldnt mint single token if supply is full");
	}

	function testTransfering()
	{	// test S0102 - modeling transfering and approving transfer
		uint a1 = 1e10;
		uint a2 = 2e10;
		uint pay = 5e9;

		inst.mint(address(user1), a1);
		inst.mint(address(user2), a2);

		user1.transfer(user2, pay);
		Assert.equal(inst.balanceOf(user1), 	a1 - pay, 		"S010201: Should decrease balance of sender");
		Assert.equal(inst.balanceOf(user2), 	a2 + pay, 		"S010202: Should increase balance of reciever");
		Assert.isFalse(user1.transfer(user2, uint(-1)), 		"S010203: Shouldnt transfer overflow");
		Assert.isFalse(user1.transfer(user2, 0), 				"S010204: Shouldnt transfer 0");
		Assert.isFalse(user1.transfer(user2, a1 + 1), 			"S010205: Shouldnt transfer more than available");
	}

	function testApproveTransfer()
	{// test S0103 - modeling allowance for transfering tokens
		uint limit = 1e12;
		user1.approve(this, limit);
		Assert.equal(inst.allowance(user1, this), limit, 		"S010301: Should be able to approve with 0 balance");

		uint eps = 1;
		user1.approve(this, limit + eps);
		Assert.equal(inst.allowance(user1, this), limit + eps, 	"S010302: Should replace allowance");
		Assert.isFalse(inst.transferFrom(user1, user2, 1e10), 	"S010303: Allowance doesnt guarantee transfer");

		inst.mint(user1, 3*limit);
		Assert.isFalse(inst.transferFrom(user1, user2, 3*limit), "S010304: Shoudnt transfer more than allowane");
		
		inst.transferFrom(user1, user2, limit);
		Assert.equal(inst.balanceOf(user1), 2*limit, 			"S010305: Should decrease balance of sender");
		Assert.equal(inst.balanceOf(user2), limit, 				"S010306: Should increase balance of reciever");
		Assert.equal(inst.allowance(user1, this), eps, 			"S010307: Should decrease allowance");

		inst.transferFrom(user1, this, eps);
		Assert.equal(inst.allowance(user1, this), 0, 			"S010308: Should exhaust allowance");
	}

	function testSimpleBurning() 
	{	// test S0104 - modeling burning single
		uint smallAmmount = 1e10;
		inst.mint(this, smallAmmount);

		uint expectedBurned = inst.burnedTokens() + smallAmmount;
		uint expectedSupply = inst.totalSupply() - smallAmmount;
		inst.burnBalance(this);
		Assert.equal(inst.balanceOf(this), 0, 					"S010401: Burning account should result in 0 balance");
		Assert.equal(inst.totalSupply(), expectedSupply, 		"S010402: Burning account should result in supply decrease");
		Assert.equal(inst.burnedTokens(), expectedBurned, 		"S010403: Burning account should result in burnedTokens increase");
		
		// using proxy to test throwing
		proxy.burnBalance(this);
		Assert.isFalse(proxyImpl.execute.gas(1e5)(), 			"S010404: Should throw when trying to burn from not owner");

		transferOwnerToProxy();
		proxy.burnBalance(this);
		Assert.isFalse(proxyImpl.execute.gas(1e5)(), 			"S010405: Should throw when trying to burn 0 ammount");
		transferOwnerToTest();
		assert(inst.owner() == address(this));		// make sure transfer owner works
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

// ======= Helper contract for proxy sending tokens ===============
contract ProxyUser
{
	TokenCAP 	inst;		// Instance of TokenCAP
	function ProxyUser(address _inst) { inst = TokenCAP(_inst); }
	function transfer(address _to, uint _amount) returns (bool success)
		{ return inst.transfer(_to, _amount); } 
	function transferFrom(address _from, address _to, uint _amount) returns (bool success)
		{ return inst.transferFrom(_from, _to, _amount); } 
	function approve(address _spender, uint _amount) returns (bool success) 
		{ return inst.approve(_spender, _amount); }
	function remove()
		{ selfdestruct(msg.sender); }
}