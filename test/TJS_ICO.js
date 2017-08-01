var TokenCAP = artifacts.require("./TokenCAP.sol");
var ICOControll = artifacts.require("./icoController.sol");
var expect = require("chai").expect;

// ============= Test suite for ICO functionality ==================
// @using async + await
// @using chai for parsing and assertion
contract('ICO', function(accounts) 
{
	it("Should link token to ICO controll", function()
	{ 
		return ICOControll.deployed()
		.then(function(instance) 
			{  return instance.capDB.call();  })
		.then(function(adr) 
			{ assert.equal(adr.valueOf(), TokenCAP.address, "Address for CAP databse in controll is invalid"); })
		.then(function()
		{  
			return TokenCAP.deployed()
			.then(function(instance2) 
				{  return instance2.owner.call(); })
			.then(function(adr) 
				{ assert.equal(adr.valueOf(), ICOControll.address, "Address for controll in database is invalid"); });
		});
	});
	// TODO: test ICO functions
});