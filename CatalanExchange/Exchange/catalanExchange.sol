pragma solidity ^0.5.0;

import "./Migrations.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@studydefi/money-legos/kyber/contracts/KyberNetworkProxy.sol";
import "@studydefi/money-legos/uniswap/contracts/IUniswapFactory.sol";
import "@studydefi/money-legos/uniswap/contracts/IUniswapExchange.sol";


contract catalanExchange is Migrations{
 
	IUniswapFactory public uniswapFactory;
	KyberNetworkProxy public kyber;
	IUniswapExchange uniswapInterface1; //DAI

	uint256 deadline = 420;
	uint256 public unity = 1000000000000000000;




	IERC20 eth;
	IERC20 dai;
	IERC20 knc;
	IERC20 mana;
	
	constructor(address _kncAddress, address _ethAddress, address _daiAddress, address _manaAddress, IUniswapFactory UniswapFactoryAddress, KyberNetworkProxy KyberNetworkProxyAddress) public{
		eth = IERC20(_ethAddress);
		dai = IERC20(_daiAddress);
		knc = IERC20(_kncAddress);
		mana = IERC20(_manaAddress);
		uniswapFactory = IUniswapFactory(UniswapFactoryAddress);
		uniswapInterface1 = IUniswapExchange(uniswapFactory.getExchange(_daiAddress));
		kyber = KyberNetworkProxy(KyberNetworkProxyAddress);
	} 
	function() external payable{}

	

	function transferRapid(uint256 _amount, uint256 _caso) external{
		uint256 x;
		address payable clientPay = address(uint160(msg.sender));

		if(_caso == 1){//DAI - ETH
			require(dai.balanceOf(msg.sender) >= _amount, "Not Enought Tokens");
			dai.transferFrom(msg.sender, address(this), _amount);
			x = buyDaiToEth2(_amount);
			clientPay.transfer(x);
		}
		if(_caso == 2){//KNC - ETH
			require(knc.balanceOf(msg.sender) >= _amount, "Not Enought Tokens");
			knc.transferFrom(msg.sender, address(this), _amount);
			x = buyKncToEth2(_amount);
			clientPay.transfer(x);
		}
		if(_caso == 3){//MANA - ETH
			require(mana.balanceOf(msg.sender) >= _amount, "Not Enought Tokens");
			mana.transferFrom(msg.sender, address(this), _amount);
			x = buyManaToEth2(_amount);
			clientPay.transfer(x);
		}
		if(_caso == 4){//DAI - KNC
			require(dai.balanceOf(msg.sender) >= _amount, "Not Enought Tokens");
			dai.transferFrom(msg.sender, address(this), _amount);
			x = buyDaiToKnc2(_amount);
			knc.transfer(clientPay, x);
		}
		if(_caso == 5){//KNC - DAI
			require(knc.balanceOf(msg.sender) >= _amount, "Not Enought Tokens");
			knc.transferFrom(msg.sender, address(this), _amount);
			x = buyKncToDai2(_amount);
			dai.transfer(clientPay, x);
		}
		if(_caso == 6){//MANA - KNC
			require(mana.balanceOf(msg.sender) >= _amount, "Not Enought Tokens");
			mana.transferFrom(msg.sender, address(this), _amount);
			x = buyManaToKnc2(_amount);
			knc.transfer(clientPay, x);
		}
		if(_caso == 7){//MANA - DAI
			require(mana.balanceOf(msg.sender) >= _amount, "Not Enought Tokens");
			mana.transferFrom(msg.sender, address(this), _amount);
			x = buyManaToDai2(_amount);
			dai.transfer(clientPay, x);
		}
		if(_caso == 8){//DAI - MANA
			require(dai.balanceOf(msg.sender) >= _amount, "Not Enought Tokens");
			dai.transferFrom(msg.sender, address(this), _amount);
			x = buyDaiToMana2(_amount);
			mana.transfer(clientPay, x);
		}
		if(_caso == 9){//KNC - MANA
			require(knc.balanceOf(msg.sender) >= _amount, "Not Enought Tokens");
			knc.transferFrom(msg.sender, address(this), _amount);
			x = buyKncToMana2(_amount);
			mana.transfer(clientPay, x);
		}
	}

	//Compra de cryptos ETH / DAI / WBTC
	//Kyber BUY (2)
	function buyDaiToEth2(uint256 _amount) internal returns(uint256 result){ 
		uint256 x;
		(x, ) = kyber.getExpectedRate(dai, eth, unity);
		dai.approve(address(kyber), _amount);
		return kyber.swapTokenToEther(dai, _amount, x);
	}
	function buyEthToDai2(uint256 _amount) external payable returns(uint256 result){
		require (msg.value >= _amount, "No dispone del Eth necesario");
		uint256 x;
		(x , ) = kyber.getExpectedRate(eth, dai, unity);
		x = kyber.swapEtherToToken.value(_amount)(dai, x);
		dai.approve(msg.sender, x);
		dai.transferFrom(address(this), msg.sender, x);	
		return x;
	}
	function buyKncToEth2(uint256 _amount) internal returns(uint256 result){
		uint256 x;
		(x, ) = kyber.getExpectedRate(knc, eth, unity);
		knc.approve(address(kyber), _amount);
		return kyber.swapTokenToEther(knc, _amount, x);
	}
	function buyEthToKnc2(uint256 _amount) external payable returns(uint256 result){
		require (msg.value >= _amount, "No dispone del Eth necesario");
		uint256 x;
		(x , ) = kyber.getExpectedRate(eth, knc, unity);
		x = kyber.swapEtherToToken.value(_amount)(knc, x);
		knc.approve(msg.sender, x);
		knc.transfer(msg.sender, x);	
		return x;
	}
	function buyDaiToKnc2(uint256 _amount) internal returns(uint256 result){
		uint256 x;
		(x, ) = kyber.getExpectedRate(dai, knc, unity);
		dai.approve(address(kyber), _amount);
		return kyber.swapTokenToToken(dai, _amount, knc, x);
	}
	function buyKncToDai2(uint256 _amount) internal returns(uint256 result){
		uint256 x;
		(x, ) = kyber.getExpectedRate(knc, dai, unity);
		knc.approve(address(kyber), _amount);
		return kyber.swapTokenToToken(knc, _amount, dai, x);

	}
	function buyManaToEth2(uint256 _amount) internal returns(uint256 result){
		uint256 x;
		(x, ) = kyber.getExpectedRate(mana, eth, unity);
		mana.approve(address(kyber), _amount);
		return kyber.swapTokenToEther(mana, _amount, x);
	}
	function buyManaToDai2(uint256 _amount) internal returns(uint256 result){
		uint256 x;
		(x, ) = kyber.getExpectedRate(mana, dai, unity);
		mana.approve(address(kyber), _amount);
		return kyber.swapTokenToToken(mana, _amount, dai, x);

	}
	function buyManaToKnc2(uint256 _amount) internal returns(uint256 result){
		uint256 x;
		(x, ) = kyber.getExpectedRate(mana, knc, unity);
		mana.approve(address(kyber), _amount);
		return kyber.swapTokenToToken(mana, _amount, knc, x);
	}
	function buyKncToMana2(uint256 _amount) internal returns(uint256 result){
		uint256 x;
		(x, ) = kyber.getExpectedRate(knc, mana, unity);
		knc.approve(address(kyber), _amount);
		return kyber.swapTokenToToken(knc, _amount, mana, x);
	}
	function buyDaiToMana2(uint256 _amount) internal returns(uint256 result) {
		uint256 x;
		(x, ) = kyber.getExpectedRate(dai, mana, unity);
		dai.approve(address(kyber), _amount);
		return kyber.swapTokenToToken(dai, _amount, mana, x);
	}
	
	function buyEthToMana2(uint256 _amount) external payable returns(uint256 result){
		require (msg.value >= _amount, "No dispone del Eth necesario");
		uint256 x;
		(x , ) = kyber.getExpectedRate(eth, mana, unity);
		x = kyber.swapEtherToToken.value(_amount)(mana, x);
		mana.approve(msg.sender, x);
		mana.transfer(msg.sender, x);	
		return x;
	}


	function newOwner(address _newOwnerAddres) external onlyOwner{
		changeOwner(_newOwnerAddres);
	}
	//Funciones para cambiar y consultar los parametros basicos
	function changeParameters(uint256 _deadline, uint256 _unity) external onlyOwner{
		deadline = _deadline;
		unity = _unity;
	}
	function getParameters() external view returns(uint256 _deadline, uint256 _unity){
		return(deadline, unity);
	}
}
