pragma solidity ^0.5.0;

import "./DappToken.sol";
import "./DaiToken.sol";

contract TokenGenerator {
	
	string public name = "Dapp Token TokenGenerator";
	DappToken public dappToken;
	DaiToken public daiToken;
	address[] public stakers;
	address public owner;
	mapping (address => uint) public stakeBalance;
	mapping (address => bool) public hasStaked;
	mapping (address => bool) public isStaking;
	
	
	constructor (DappToken _dappToken, DaiToken _daiToken) public {
		dappToken = _dappToken;
		daiToken = _daiToken;
		owner = msg.sender;
	}

	modifier onlyOwner() { 
		require(msg.sender == owner, "Only owner can issue tokens"); 
		_; 
	}
	

	function stakeTokens (uint _amount) public{


		require (_amount > 0, 'Amount cannot  be 0');
		

		daiToken.transferFrom(msg.sender, address(this), _amount);


		stakeBalance[msg.sender] = stakeBalance[msg.sender] + _amount;

		if(!hasStaked[msg.sender]){
			stakers.push(msg.sender);
		}

		isStaking[msg.sender] = true;
		hasStaked[msg.sender] = true;
	}
	
	
	function issueTokens () onlyOwner public{
		for (uint i=0; i<stakers.length; i++){

			address recipent = stakers[i];
			uint balance = stakeBalance[recipent];

			if (balance > 0){
				dappToken.transfer(recipent, balance);
				stakeBalance[recipent] = stakeBalance[recipent] - balance; 
			}
		}
	}


	function unstakeTokens () public {
		
		uint balance = dappToken.balanceOf(msg.sender);

		require (balance > 0, 'Dapp token cannot be zero');

		daiToken.transfer(msg.sender, balance);
		dappToken.transferFrom(msg.sender, address(this), balance);

		isStaking[msg.sender] = false;						
	}
	
	
}

