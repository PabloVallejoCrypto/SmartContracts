pragma solidity ^0.8.0;

//Basic library
import "./Migrations.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

//Here start Chaotic ERC20 Token version 1
//I hope you enjoy it, if want to read or reuse that code you are free to go.

//	SPDX-License-Identifier: CC-BY-NC-4.0
//	Author: Pablo Vallejo

contract ChaoticToken is Migrations, ERC20{
 	//Declaration of basic parameters
 	uint256 totalContractSupply;	//Initial Supply
 	uint256 timeUnity;		//Voting Time Delay

	uint256 unity;		//Unity 10^18
	uint256 supplyIncrement;	//The amount of supply to mint
	bool bossVeto;		//Basic control for inflation/deflation:	false => voting allowed; true => voting disallowed;
	uint256 referendumId;		//Number of votings done
	constructor() ERC20("CHAOS1", "\x58\xce\x9f\xce\xa3"){
		unity = 10 ** 18;
		bossVeto = false;
		referendumId = 0;
		totalContractSupply = 18000000 * unity;
		timeUnity = 1 hours; //Change to weeks (Hours for testing)
		supplyIncrement = 1000000 * unity;

		//Initial Sypply MINT
		_mint(payable(msg.sender), 18000000 * unity);//As it's for testing right now I get all initial supply, but it'll be sended to another contract for buying and staking
	} 
	receive() external payable{}
	//Democratic Mint Mapping
	mapping (uint256 => uint256) private voteMapping; //[0] => num of votes; [1] => result; [2] => supply voted
	mapping (address => uint256) private hasVoted;
	mapping (uint256 => uint256[3]) public historicalReferendums;	//Num persons voted, result, time

	//Democratic Mint Functions
	function countVotes() internal view returns(uint256 _result){
		uint256 x = 0; //Counter Votes
		uint256 y = voteMapping[0]; //Counter Persons Left
		while(y > 1){
			if(voteMapping[y] > 0) {
				x++;
			}
			y--;			
		}
		if(2 * x > voteMapping[0]){
			return x;
		}else {
			return 0;
		}
	}
	function democraticMint(uint256 _vote) external {
		require (!bossVeto && hasVoted[msg.sender] != referendumId && (_vote == 1 || _vote == 0),  "Mint not allowed or already voted.");
		if(voteMapping[0] > 0){		//If the referendum has already started
			voteMapping[0]++;	//One vote more for voting count
			voteMapping[voteMapping[0]] = _vote;	//Vote positive or negative
			voteMapping[2] += this.balanceOf(msg.sender);
			hasVoted[msg.sender] = referendumId;	//Has voted mapping
			if(block.timestamp >= voteMapping[1]){
				if(voteMapping[2] <= ((totalContractSupply * 5) / 100)){ //If total voters does not have the 5% of total Supply the referendum does not have any future :(
					voteMapping[0] = 0;
					return;
				}
				//Reflect This Referendum into Historical Referendums Record
				historicalReferendums[referendumId][0] = voteMapping[0];
				historicalReferendums[referendumId][1] = countVotes();
				historicalReferendums[referendumId][2] = block.timestamp;
				//Reset voteMapping
				voteMapping[0] = 0;
				if(historicalReferendums[referendumId][1] > 0){
					_mint(payable(this), supplyIncrement);
					totalContractSupply *= supplyIncrement;
				}
			}
		}else {		//If you're the first to vote you too start the referendum
			referendumId++;
			voteMapping[1] = block.timestamp + timeUnity;
			voteMapping[2] = this.balanceOf(msg.sender);
			voteMapping[3] = _vote;
			voteMapping[0] = 3;
		}
	}
	//Function to get all results of all referendums done, all must be public!
	function getReferendum(uint256 _referendumId) external view returns(uint256 _totalVotes, uint256 _referendumResult, uint256 _endTime){
		return (historicalReferendums[_referendumId][0], historicalReferendums[_referendumId][1], historicalReferendums[_referendumId][2]);
	}
	//Basic inflation/deflation control
	function changeVeto() external onlyOwner {
		bossVeto = !bossVeto;
	}
	//Function to change the owner
	function newOwner(address _newOwnerAddres) external onlyOwner{
		changeOwner(_newOwnerAddres);
	}
	
//Thanks to check this out, it's important that we keep a basic understanding on those tokens we use and buy, for that Ethereum BlockChain is one of the best ways.
//See you on other DAPP !
}



