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

	function Test_CAP()
	{// setup
		inst = new TokenCAP();
		proxyImpl = new ThrowProxy(address(inst));
		proxy = TokenCAP(address(proxyImpl));
	}

	function testMinting()
	{// test S0101 - modeling minting tokens
		TokenCAP cap = new TokenCAP();
		ProxyUser p = new ProxyUser(cap);
		Assert.equal(cap.balanceOf(this), 	0, 				"S010101: Owner should have 0 balance initially");

		uint smallAmmount = 1e10;
		cap.mint(p, smallAmmount);
		Assert.equal(cap.balanceOf(p), 		smallAmmount, 	"S010102: Minting should increase balance");
		Assert.equal(cap.mintedTokens(), 	smallAmmount, 	"S010103: Minting should increase mintedTokens");
		Assert.equal(cap.activeTokens(), 	smallAmmount, 	"S010104: Minting should increase activeTokens");

		cap.mint(p, smallAmmount);
		Assert.equal(cap.balanceOf(p), 		2*smallAmmount, "S010105: Minting should be additive");

		Assert.isFalse(cap.mint(this, uint(-1)), 			"S010106: Shouldnt mint if overflow");
		Assert.isFalse(cap.mint(this, cap.totalSupply()), 	"S010107: Shouldnt mint if supply isnt enough");

		uint leftOver = cap.totalSupply() - cap.activeTokens();
		cap.mint(this, leftOver);
		Assert.equal(cap.balanceOf(this), leftOver, 		"S010108: Minting can create full supply");

		Assert.isFalse(cap.mint(this, 1), 					"S010109: Shouldnt mint single token if supply is full");

		p.remove();
	}

	function testTransfering()
	{	// test S0102 - modeling transfering and approving transfer
		ProxyUser p1 = new ProxyUser(inst);
		ProxyUser p2 = new ProxyUser(inst);

		uint a1 = 1e10;
		uint a2 = 2e10;
		uint pay = 5e9;

		inst.mint(address(p1), a1);
		inst.mint(address(p2), a2);

		p1.transfer(p2, pay);
		Assert.equal(inst.balanceOf(p1), 	a1 - pay, 		"S010201: Should decrease balance of sender");
		Assert.equal(inst.balanceOf(p2), 	a2 + pay, 		"S010202: Should increase balance of reciever");
		Assert.isFalse(p1.transfer(p2, uint(-1)), 			"S010203: Shouldnt transfer overflow");
		Assert.isFalse(p1.transfer(p2, 0), 					"S010204: Shouldnt transfer 0");
		Assert.isFalse(p1.transfer(p2, a1 + 1), 			"S010205: Shouldnt transfer more than available");

		p1.remove();
		p2.remove();
	}

	function testSimpleBurning() 
	{	// test S0102 - modeling burning single
		uint smallAmmount = 1e10;
		inst.mint(this, smallAmmount);

		uint expectedBurned = inst.burnedTokens() + smallAmmount;
		uint expectedSupply = inst.totalSupply() - smallAmmount;
		inst.burnBalance(this);
		Assert.equal(inst.balanceOf(this), 0, 				"S010301: Burning account should result in 0 balance");
		Assert.equal(inst.totalSupply(), expectedSupply, 	"S010302: Burning account should result in supply decrease");
		Assert.equal(inst.burnedTokens(), expectedBurned, 	"S010303: Burning account should result in burnedTokens increase");
		
		// using proxy to test throwing
		proxy.burnBalance(this);
		Assert.isFalse(proxyImpl.execute.gas(1e5)(), 		"S010304: Should throw when trying to burn from not owner");

		transferOwnerToProxy();
		proxy.burnBalance(this);
		Assert.isFalse(proxyImpl.execute.gas(1e5)(), 		"S010305: Should throw when trying to burn 0 ammount");
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