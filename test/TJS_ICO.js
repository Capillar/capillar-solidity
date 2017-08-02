require('babel-polyfill');

var TokenCAP = artifacts.require("./TokenCAP.sol");
var ICOControll = artifacts.require("./icoController.sol");
var expect = require("chai").expect;

var ico;
var cap;

// ============= Test suite for ICO functionality ==================
// @using async + await
// @using chai for parsing and expect chain synthax
contract('ICO', function(accounts) 
{
	it("Should link token to ICO control", async function()
	{ 
		// ico = await ICOControll.deployed();
		// cap = await TokenCAP.deployed();

		// var icoDB = await ico.capDB.call();
		// var capICO = await cap.owner.call();

		// expect(icoDB).to.equal(cap);
		// expect(capICO).to.equal(ico);
	});
	// TODO: test ICO functions
});