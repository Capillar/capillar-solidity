var TokenCAP = artifacts.require("./TokenCAP.sol");
var ICOControll = artifacts.require("./icoController.sol");
var expect = require("chai").expect;

// ============= Test suite for ICO functionality ==================
// @using chai for parsing and assertion
contract('ICO', function(accounts) 
{
	it("Should link token to ICO controll", function()
	{ 
		return ICOControll.deployed()
		.then(function(instance) 
			{  return instance.capDB.call();  })
		.then(function(adr) 
			{ expect(adr.valueOf()).to.equal(TokenCAP.address); })
		.then(function()
		{  
			return TokenCAP.deployed()
			.then(function(instance2) 
				{  return instance2.owner.call(); })
			.then(function(adr) 
				{ expect(adr.valueOf()).to.equal(ICOControll.address); });
		});
	});
});