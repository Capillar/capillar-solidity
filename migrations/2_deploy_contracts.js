var TokenCAP = artifacts.require("./TokenCAP.sol");
var ICOControll = artifacts.require("./icoController.sol");

module.exports = function(deployer) 
{
	deployer.deploy(TokenCAP)
	.then(function()
		{	return deployer.deploy(ICOControll, TokenCAP.address); })
	.then(function()
	{	
		return TokenCAP.deployed()
		.then(function(instance) 
			{ return instance.setOwner(ICOControll.address); });
	});
};