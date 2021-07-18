pragma solidity ^0.5.0;

import "./Migrations.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@studydefi/money-legos/kyber/contracts/KyberNetworkProxy.sol";



contract easyTutorial is Migrations{
 
	KyberNetworkProxy public kyber;


	struct user{
		string name;
		uint256 ultimRuleta;
	}
	
	uint256 adnModulus;
	uint256 maxId;
	uint256 unity;

	IERC20 eth;
	IERC20 dai;

	
	constructor(address _ethAddress, address _daiAddress, KyberNetworkProxy KyberNetworkProxyAddress) public{
		eth = IERC20(_ethAddress);
		dai = IERC20(_daiAddress);
		kyber = KyberNetworkProxy(KyberNetworkProxyAddress);
		maxId = 0;
		adnModulus = 10 ** 16;
		unity = 10 ** 18;
	} 
	function() external payable{}

	user[] usuario;

	mapping (address => uint256) addressToId;


	//Get Price & Buy KyberNetworkProxy
	function priceEthToDai(uint256 _amount) external view returns(uint256 _daiAmount){
		uint256 x;
		(x, ) = kyber.getExpectedRate(eth, dai, unity);
		x = x * _amount;
		x = (x - (x % unity)) / unity;
		return x;			
	}
	function buyEthToDai(uint256 _amount) external payable returns(uint256 result){
		require (msg.value >= _amount, "No dispone del Eth necesario");
		uint256 x;
		(x , ) = kyber.getExpectedRate(eth, dai, unity);
		x = kyber.swapEtherToToken.value(_amount)(dai, x);
		dai.approve(msg.sender, x);
		dai.transferFrom(address(this), msg.sender, x);	
		return x;
	}
					

	//New user
	function createUser(string calldata _name) external{
		require (addressToId[msg.sender] == 0, "Usuario ya registrado");
		require(dai.balanceOf(address(this)) >= unity, "Contract do not have enought DAI, sorry.");
		maxId = (usuario.push(user(_name, 0)) - 1);
		addressToId[msg.sender] = maxId;
		dai.approve(address(this), unity);
		dai.transferFrom(address(this), msg.sender, unity);
	}
	function tieneCuenta() external view returns(uint256 _cuenta){
		if(addressToId[msg.sender] == 0){
			return 1;
		}
		if(addressToId[msg.sender] >= 1){
			return 2;
		}
		return 3;
	}
	
	function getUserParams() external view returns(uint256 _idUser, string memory _nameUser, uint256 _ultimRuleta){
		require (addressToId[msg.sender] != 0, "Usuario no registrado");
		return (addressToId[msg.sender], usuario[addressToId[msg.sender]].name, usuario[addressToId[msg.sender]].ultimRuleta);		
	}
	


	
	
	function ruleta(uint256 _amount) external{
		require (dai.balanceOf(msg.sender) >= _amount, "No disposa de suficients DAI");
		require (_amount == unity, "Entrada 1 DAI");
		uint256 x = uint256(keccak256(abi.encodePacked("RuletaManda")));
		uint256 y;
		x = x % adnModulus;
		x = x * uint256(now);
		x = x % (10 ** 1);

		//Here we transfer 1 Dai from you to our Contract as pay
		//You must approve it before, for sure
		dai.transferFrom(msg.sender, address(this), unity);

		if(x == 0){
			y = 9 * (10 ** 17);
			dai.approve(address(this), y);
			dai.transferFrom(address(this), msg.sender, y);//Retorna 0.9 Dai
		}		
		if(x == 1){
			y = 15 * (10 ** 17);
			dai.approve(address(this), y);
			dai.transferFrom(address(this), msg.sender, y);//Retorna 0.8 Dai
		}
		if(x == 2){
			y = 2 * (10 ** 18);
			dai.approve(address(this), y);
			dai.transferFrom(address(this), msg.sender, y);//Retorna 2 Dai
		}
		if(x == 3){
			y = 5 * (10 ** 17);
			dai.approve(address(this), y);
			dai.transferFrom(address(this), msg.sender, y); //Retorna 0.5 Dai
		}
		if(x == 4){
			y = 8 * (10 ** 17);
			dai.approve(address(this), y);
			dai.transferFrom(address(this), msg.sender, y);//Retorna 0.8 Dai
		}
		if(x == 5){
			y = 6 * (10 ** 17);
			dai.approve(address(this), y);
			dai.transferFrom(address(this), msg.sender, y);//Retorna 0.6 Dai
		}
		if(x == 6){
			y = 5 * (10 ** 17);
			dai.approve(address(this), y);
			dai.transferFrom(address(this), msg.sender, y); //Retorna 0.5 Dai
		}
		if(x == 7){
			y = 5 * (10 ** 17);
			dai.approve(address(this), y);
			dai.transferFrom(address(this), msg.sender, y);//Retorna 0.5 Dai
		}
		if(x == 8){
			y = 6 * (10 ** 17);
			dai.approve(address(this), y);
			dai.transferFrom(address(this), msg.sender, y);//Retorna 0.6 Dai
		}
		if(x == 9){
			y = 8 * (10 ** 17);
			dai.approve(address(this), y);
			dai.transferFrom(address(this), msg.sender, y);//Retorna 0.8 Dai
		}
		//Gracias por darle al vicio
	}
	
	function takeBenefits() external onlyOwner{
		uint256 x = 0;
		x = uint256(dai.balanceOf(address(this)));
		dai.approve(msg.sender, x);
		dai.transferFrom(address(this), msg.sender, x);		
	}
	
	





	//Change Parameters
	function newOwner(address _newOwnerAddres) external onlyOwner{
		changeOwner(_newOwnerAddres);
	}

}
