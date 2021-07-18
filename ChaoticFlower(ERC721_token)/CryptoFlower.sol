pragma solidity ^0.8.0;

//Basic library
import "./Migrations.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol";

//	SPDX-License-Identifier: CC-BY-NC-4.0
//	Author: Pablo Vallejo

contract CryptoFlower is Migrations, ERC721PresetMinterPauserAutoId {
 	//Declaration of CHAOS (as IERC20) and other parameters
	IERC20 chaos;
	uint256 unity;
	uint256 maxId;
	uint256 minAmount;
	uint256 maxAmount;
	constructor(address _chaosAddress) ERC721PresetMinterPauserAutoId("UniversalSEED", "SEED", "https://www.chaoticbcn.com/flower/"){
		chaos = IERC20(_chaosAddress);
		unity = 10 ** 18;
		maxId = 0;
		minAmount = 50 * unity;
		maxAmount = 1000 * unity;

		//mint for ERC721
		_mint(msg.sender, 18);
	} 
	receive() external payable{}
	//Is alive mapping
	mapping (uint256 => uint256) private isAlive;
	mapping (address => uint256[]) public ownerToIds;

	//User help to do random number
	mapping (address => uint256) private addressToId;
	mapping (uint256 => address) private idToAddress;
	//Add to User mapping
	modifier addUser() { 
		if(addressToId[msg.sender] == 0){
			addressToId[msg.sender] = maxId;
			idToAddress[maxId] = msg.sender;
			maxId++;
		}
		_; 
	}
	//Random Generator
	function random_rtq(uint256 _amount) internal addUser returns(uint256 _result){//Signature 0x00003147
		uint256 auxAmount = _amount - (_amount % unity);
		uint256 x = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, block.number, "chaotic")));//Initial seed + time + caller address + block number
		uint256 blockHashNow = uint256(blockhash(block.number - 1));//BlockHash
		x = x % maxId;//Number must be bellow maxId obviously
		x = uint256(uint160(idToAddress[x]));//Random address is selected and tranformed to uint256
		x = uint256(keccak256(abi.encodePacked(blockHashNow, x, block.coinbase)));//The implementation of BlockHash and the miner address, just for fun
		x = x - (x % 100); //aixo s'ha d'arreglar
		x = x / auxAmount;
		x = x % unity;
		return (x);
	}
	//Token Generator  FALTA EL EVENTO
	function buyToken(uint256 _amount) public returns(uint256 _tokenId){
		require (chaos.balanceOf(msg.sender) >= _amount && _amount >= minAmount && _amount <= maxAmount, "Error in your balance account or amount payed.");
		//Find a new SEED (x)
		uint256 x = random_rtq(_amount);
		while (isAlive[x] != 0) {
			x = random_rtq(_amount);
		}
		//Transfer the amount as costs
		chaos.transferFrom(msg.sender, payable(this), _amount);
		//Mint the token and block their value into isAlive mapping
		_mint(msg.sender, x);
		isAlive[x] = _amount;
		return x;
	}
	function isFlowerAlive(uint256 _tokenId) external view returns(uint256 _value){
		return (isAlive[_tokenId]);
	}
	//Set Up
	function createTokenOwner(uint256 _tokenId, uint256 _value) external onlyOwner {
		require (isAlive[_tokenId] == 0, "Flower already alive.");
		_mint(msg.sender, _tokenId);
		isAlive[_tokenId] = _value;
	}
	function takeBenefits() external onlyOwner{
		uint256 x = uint256(chaos.balanceOf(address(this)));
		chaos.approve(msg.sender, x);
		chaos.transferFrom(address(this), msg.sender, x);
	}
	function newOwner(address _newOwnerAddres) external onlyOwner{
		changeOwner(_newOwnerAddres);
	}
	function changeParams(uint256 _minAmount, uint256 _maxAmount) external onlyOwner{
		minAmount = _minAmount;
		maxAmount = _maxAmount;
	}
	function getParams() external view returns(uint256 _maxId, uint256 _minAmount, uint256 _maxAmount){
		return (maxId, minAmount, maxAmount);
	}

}



