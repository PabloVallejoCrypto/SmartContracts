pragma solidity ^0.5.0;

import "./Migrations.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract votingDapp is Migrations{

	uint256 unity;
	uint32 maxId;
	uint32 maxIdQuest;

	struct question{
		string name;
		string description;
		uint256 initTime;
		uint256 lastTime;
		bool active;
		uint256 approved;//Base unity => approved > unity => people has voted positive, so it has been approved.		
	}
	struct user{
		uint32 lastVoted;		
	}
	

	constructor() public{
		unity = 10 ** 18;
		maxId = 0;
		maxIdQuest = 0;
	} 
	function() external payable{}

	mapping (address => uint32) addressToId;

	user[] users;
	question[] questions;
			
	modifier addUser() { 
		if(addressToId[msg.sender] == 0){
			maxId = uint32(users.push(user(0)) - 1);
			addressToId[msg.sender] = maxId;
		} 
		_; 
	}
	function wievQuest(uint256 _idQuest) external view returns(string memory _name, string memory _description, uint256 _result){
		return(questions[_idQuest].name, questions[_idQuest].description, questions[_idQuest].approved);
	}
	function viewInfo() external view returns(uint32 _maxQuestion){
		return(maxIdQuest);		
	}
	function createQuest(uint256 _time, string calldata _name, string calldata _description) external addUser{
		maxIdQuest = uint32(questions.push(question(_name, _description, now, now + _time, true, unity)) - 1);
	}
	function vote(uint32 _idQuest, uint _result) external addUser{
		require(users[addressToId[msg.sender]].lastVoted != _idQuest, "You have voted");
		require(_result <= 1,"Not between 1 - 0");// 1 positive 0 negative
		require(questions[_idQuest].active, "Finished");
		
		if(_result == 0){
			questions[_idQuest].approved--;
		}else{
			questions[_idQuest].approved++;
		}
		users[addressToId[msg.sender]].lastVoted = _idQuest;		
	}
	function ownerClose() external onlyOwner{
		uint256 i;
		for(i=0;i<=maxIdQuest;i++){
			if(questions[i].lastTime <= now && questions[i].active){
				questions[i].active = false;
			}
		}
	}
	function closeQuest(uint256 _idQuest) external onlyOwner{
		questions[_idQuest].active = false;
	}

	//Change Parameters
	function newOwner(address _newOwnerAddres) external onlyOwner{
		changeOwner(_newOwnerAddres);
	}

}
