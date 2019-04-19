pragma solidity ^0.4.24;


/**
(The lode will mine automatically and emit events when it yields)

*/

contract Lode is ERC721 {

  string public constant contractName = "Lode";

  uint256 constant public RESOURCE_COUNT = 8;
  uint256 public deposit;
  uint256 public machine;
  uint256 public goldMined;
  //view the resources mined since last collection.
  uint256[RESOURCE_COUNT] resourcesMined;


  struct Lode {
    uint256 tokenID;

  }

  constructor() {

  }


  function newLode(address player, uint256 randomSelector) {

  }

  //setEquipment(uint equipment): Set the mining machine
  function setEquipment(uint256 equipment) {

  }

  //setDeposit(uint deposit): Set the deposit being mined
  function setDeposit(uint256 deposit) {

  }

  //stopMining(): set machine and deposit to zero and stop mining
  function stopMining() {

  }

  //Call a function to collect resources and gold mined */
  function collect() returns (uint256, uint256[RESOURCE_COUNT]) {

  }


}
