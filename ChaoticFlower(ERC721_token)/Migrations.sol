pragma solidity ^0.8.0;

//  SPDX-License-Identifier: CC-BY-NC-4.0
//  Author: Pablo Vallejo

contract Migrations{
  address public owner;
  uint public last_completed_migration;

  constructor() {
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
