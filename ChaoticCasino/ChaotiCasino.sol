pragma solidity ^0.5.0;

//Basic library
import "./Migrations.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

//Here start Chaotic Casino version 1
//I hope you enjoy the game, if want to read or reuse that code you are free to go.
contract ChaotiCasino is Migrations{
 	//Declaration of DAI and other parameters
	IERC20 dai;
	uint256 unity;
	uint256 maxId;
	uint8 maxWinMult;
	uint256 maxAmount;
	uint8 multiplyPerCent;
	constructor(address _daiAddress) public{
		dai = IERC20(_daiAddress);
		unity = 10 ** 18;
		maxId = 0;
		maxWinMult = 5;
		maxAmount = 5 * unity;
		multiplyPerCent = 8;
	} 
	function() external payable{}
	//User help to do random number
	mapping (address => uint256) private addressToId;
	mapping (uint256 => address) private idToAddress;
	mapping (address => uint256) lastResult; //Last result of last bet
	mapping (address => uint256) bonusResult; //Bonus winned by playing our rulettes
	modifier addUser() { 
		if(addressToId[msg.sender] == 0){
			addressToId[msg.sender] = maxId;
			idToAddress[maxId] = msg.sender;
			maxId++;
		}
		_; 
	}
	function random_rtq(uint256 _help) internal addUser returns(uint256 _result){//Signature 0x00003147
		uint256 x = uint256(keccak256(abi.encodePacked(now, msg.sender, block.number, "chaotic")));//Initial seed + time + caller address + block number
		uint256 blockHashNow = uint256(blockhash(block.number - 1));//BlockHash
		x = x % maxId;//Number must be bellow maxId obviously
		x = uint256(idToAddress[x]);//Random address is selected and tranformed to uint256
		x = uint256(keccak256(abi.encodePacked(blockHashNow, x, block.coinbase)));//The implementation of BlockHash and the miner address, just for fun
		if(_help == 1){ 
			x = x % 10;
		}
		if(_help == 2){
			x = x % 100;
		}
		return (x);
	}
	//Rulette function
	function roulette_Og2(uint256 _amount, uint256 _winMultiply) external{//Signature 0x00001ced
		require (dai.balanceOf(msg.sender) >= _amount && _amount >= unity, "No enought DAI");
		uint x;
		uint256 y = 0;
		//If crazy roulette is on
		if(_winMultiply > 1){
			require(_amount <= maxAmount && _winMultiply <= maxWinMult, "Amount or multiplier not accepted");
			x = random_rtq(2);
			uint perCent = checkPercent(_winMultiply);
			if(x <= perCent){
				y = _amount * _winMultiply;
				dai.approve(address(this), y - _amount);
				dai.transferFrom(address(this), msg.sender, y - _amount);
			}else{
			//Approved first, we transfer the bet from msg.sender
			dai.transferFrom(msg.sender, address(this), _amount);
			y = 0;
			}
			lastResult[msg.sender] = y;
			return;
		}
		//Else normal roulette
		x = random_rtq(1);
		if(x == 0){
			y = unity;
		}
		if(x >= 1 && x <= 8){
			y = x * (10 ** 17);
			dai.transferFrom(msg.sender, address(this), unity - y);//Gets just the restant part of the unity
		}
		if(x == 9){
			y = 2;
			dai.approve(address(this), unity);
			dai.transferFrom(address(this), msg.sender, unity);//Retorns +1 => 2 DAI
		}
		lastResult[msg.sender] = y;
		bonusResult[msg.sender] += y;
		return;
		//Thanks to join our game
	}
	//Each of the following functions are used to acces to their personal result of each game
	function getLastResult() external view returns(uint256 _lastResult){
		return(lastResult[msg.sender]);
	}
	function resetBonus(address _user) external onlyOwner{//To charge the gift
		bonusResult[_user] = 0;
	}
	function getBonusResult() external view returns(uint256 _bonusResult){
		return(bonusResult[msg.sender]);
	}
	//% of crazy rulette
	function checkPercent(uint256 _winMultiply) public view returns(uint256 _tantpercent){
		uint256 x = 100 * unity;
		uint256 y = unity * _winMultiply;
		uint256 auxf = y % multiplyPerCent;
		auxf = (y - auxf) / multiplyPerCent;
		y = y + auxf;
		auxf = x % y;
		x = (x - auxf) / y;
		return x;
	}
	//Set Up
	function takeBenefits() external onlyOwner{
		uint256 x = uint256(dai.balanceOf(address(this)));
		dai.approve(msg.sender, x);
		dai.transferFrom(address(this), msg.sender, x);
	}
	function newOwner(address _newOwnerAddres) external onlyOwner{
		changeOwner(_newOwnerAddres);
	}
	function changeParams(uint256 _maxAmount, uint256 _newMaxId, uint8 _newMaxWinMult, uint8 _multiplyPerCent) external onlyOwner{
		maxAmount = _maxAmount;
		maxId =  _newMaxId;
		maxWinMult = _newMaxWinMult;
		multiplyPerCent = _multiplyPerCent;
	}
	function getParams() external view onlyOwner returns(uint256 _maxAmount, uint256 _maxId, uint8 _MaxWinMult, uint8 _multiplyPerCent){
		return(maxAmount, maxId, maxWinMult, multiplyPerCent);
	}
//Thanks to check this out, it's important that we keep a basic understanding on those games we play and put money on it, for that Ethereum BlockChain is one of the best ways.
//See you on other DAPP !
}



