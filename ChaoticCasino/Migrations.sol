pragma solidity ^0.5.0;


contract Migrations{
  address private owner;
  uint public last_completed_migration;

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
     require(msg.sender == owner, "Not Owner");
      _;
  }
  function changeOwner(address newOwner) public onlyOwner{
    owner = newOwner;    
  }
  function setCompleted(uint completed) public {
    last_completed_migration = completed;
  }
}
