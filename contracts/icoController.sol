pragma solidity ^0.4.11;

import "./interfaces/iTokenCAP.sol";

//====== ICO contract - controller for CAP minting during ICO ================
contract icoController is owned
{
	uint public constant	tokenLimit = 9e18;	// minting for ICO is limited to 90 % of all tokens
	uint public				distributed = 0;	// ammount of distributed (minted) tokens
	iTokenCAP	public 		capDB;				// address for CAP tokens database
	bool public				isFinished = false; // flag of finishing ICO
	address public			team = 0x0;			// Address for tokens left for team

	function icoController(address _db) { capDB = iTokenCAP(_db); }
	function () payable { assert(false); } // fallback

	modifier finished
		{ require(isFinished); _; }
	modifier inProgress
		{ require(!isFinished); _; }

	// --------- Interface of ICO lifecycle ---------------------
	event ICOStopped();

	function setTeam(address _newTeam) onlyOwner inProgress
	{// determine address for team tokens
		team = _newTeam;
	}
	function stopICO() onlyOwner inProgress         
	{// Stop ICO - enables transfering control
		require(team != 0x0);
		if(distributed < tokenLimit)
		{// minting undistributed tokens for team
			uint dif = tokenLimit - distributed;
			distributed = tokenLimit;
			require(capDB.mint(team, dif));
			capDB.limitAccount(team, dif);	// team cannot transfer tokens
		}
		isFinished = true; 
		ICOStopped();   
	}
	function transferControl(address _hier) onlyOwner finished
	{// Transfer control from ICO to platform
		capDB.setOwner(_hier);
		selfdestruct(msg.sender);
	}

	// --------- Interface of ICO operations ---------------------
	function undistributedTokens() constant returns(uint amount)
		{ return tokenLimit - distributed; }

	function distributeTokens(address _to, uint _amount) onlyOwner inProgress
	{
		require(distributed + _amount > distributed); 	// overflow and zero check
		require(distributed + _amount <= tokenLimit); 	// make sure minting on ICO is limited
		require(capDB.mint(_to, _amount));				// do the minting
		distributed += _amount;
	}
}