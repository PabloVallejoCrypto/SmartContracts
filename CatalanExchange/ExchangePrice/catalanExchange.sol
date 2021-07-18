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

	//Preus i conversions (Uniswap = 1 && Kyber == 2)
	function priceDaiToEth1(uint256 _amount) external view returns(uint256 _daiToEth, uint256 _ethToDai){
		uint256 x = uniswapInterface1.getTokenToEthInputPrice(_amount);
		uint256 y = uniswapInterface1.getEthToTokenInputPrice(_amount);
		return (x, y);	
	}
	function priceDaiToEth2(uint256 _amount) external view returns(uint256 daiToEthKyber, uint256 ethToDaiKyber){
		uint256 x;
		uint256 a;
		(x, ) = kyber.getExpectedRate(dai, eth, unity);
		a = (x * _amount) - ((x * _amount) % unity);
		x = a / unity;
		uint256 y; 
		(y, ) = kyber.getExpectedRate(eth, dai, unity);
		a = (y * _amount) - ((y * _amount) % unity);
		y = a / unity;
		return (x, y);
	}
	function priceKncToEth2(uint256 _amount) external view returns(uint256 knkToEthKyber, uint256 ethToKnkKyber){
		uint256 x;
		uint256 a;
		(x, ) = kyber.getExpectedRate(knc, eth, unity);
		a = (x * _amount) - ((x * _amount) % unity);
		x = a / unity;
		uint256 y; 
		(y, ) = kyber.getExpectedRate(eth, knc, unity);
		a = (y * _amount) - ((y * _amount) % unity);
		y = a / unity;
		return (x, y);
	}
	function priceDaiToKnc2(uint256 _amount) external view returns(uint256 daiToKnkKyber, uint256 KnkToDaiKyber) {
		uint256 x;
		uint256 a;
		(x, ) = kyber.getExpectedRate(dai, knc, unity);
		a = (x * _amount) - ((x * _amount) % unity);
		x = a / unity;
		uint256 y; 
		(y, ) = kyber.getExpectedRate(knc, dai, unity);
		a = (y * _amount) - ((y * _amount) % unity);
		y = a / unity;
		return (x, y);
	}
	function priceManaToEth2(uint256 _amount) external view returns(uint256 manaToEth, uint256 ethToMana){
		uint256 x;
		uint256 a;
		(x, ) = kyber.getExpectedRate(mana, eth, unity);
		a = (x * _amount) - ((x * _amount) % unity);
		x = a / unity;
		uint256 y; 
		(y, ) = kyber.getExpectedRate(eth, mana, unity);
		a = (y * _amount) - ((y * _amount) % unity);
		y = a / unity;
		return (x, y);	
	}
	function priceManaToDai2(uint256 _amount) external view returns(uint256 manaToDai, uint256 daiToMana){
		uint256 x;
		uint256 a;
		(x, ) = kyber.getExpectedRate(mana, dai, unity);
		a = (x * _amount) - ((x * _amount) % unity);
		x = a / unity;
		uint256 y; 
		(y, ) = kyber.getExpectedRate(dai, mana, unity);
		a = (y * _amount) - ((y * _amount) % unity);
		y = a / unity;
		return (x, y);	
	}
	function priceManaToKnc2(uint256 _amount) external view returns(uint256 manaToKnk, uint256 knkToMana) {
		uint256 x;
		uint256 a;
		(x, ) = kyber.getExpectedRate(mana, knc, unity);
		a = (x * _amount) - ((x * _amount) % unity);
		x = a / unity;
		uint256 y; 
		(y, ) = kyber.getExpectedRate(knc, mana, unity);
		a = (y * _amount) - ((y * _amount) % unity);
		y = a / unity;
		return (x, y);
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
