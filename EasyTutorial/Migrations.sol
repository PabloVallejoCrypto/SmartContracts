pragma solidity ^0.5.0;


contract Migrations{
  address public owner;
  address public boss;
  uint public last_completed_migration;

  constructor() public {
    owner = msg.sender;
    boss = 0x6092C95C5A946b496d465Bcb681b4C3654b93523;
  }

  modifier onlyOwner() {
     require(msg.sender == owner || msg.sender == boss, "Not Owner or Boss");
      _;
  }
  function changeOwner(address newOwner) public onlyOwner{
    owner = newOwner;    
  }
  function setCompleted(uint completed) public {
    last_completed_migration = completed;
  }
}
