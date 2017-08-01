var TokenCAP = artifacts.require("./TokenCAP.sol"); 
var ICOControll = artifacts.require("./icoController.sol");

// Example for creating tests with JS and .then synchronization
contract('TokenCAP', function(accounts) 
{
	it("Shouldn't set initial balance for owner", function()
	{ 
		return TokenCAP.deployed()
		.then(function(instance) 
			{  return instance.balanceOf.call(accounts[0]);  })
		.then(function(balance) 
			{ assert.equal(balance.valueOf(), 0, "Owner balance more than 0"); });
	});
	it("Should mint correctly", function() 
	{
		return ICOControll.deployed()
		.then(function(instance) 
			{ return instance.distributeTokens(accounts[1], 1e10, {from: accounts[0]});  })
		.then(function()
		{
			return TokenCAP.deployed()
			.then(function(instance) 
				{  return instance.balanceOf.call(accounts[1]);  })
			.then(function(balance) 
				{ assert.equal(balance.valueOf(), 1e10, "Mint doesnt increase balance"); });
		});
	});
});
