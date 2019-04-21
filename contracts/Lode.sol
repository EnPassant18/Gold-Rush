pragma solidity ^0.4.24;

import "./Game.sol";
import "./Support/SafeMath.sol";

contract Lode {

  string public constant contractName = "Lode";

  address public owner;
  uint256 private seed;
  address public game;
  uint256 constant public RESOURCE_COUNT = 8;
  uint256 public deposit;
  uint256 public equipment;
  uint256 public goldMined;
  uint256[RESOURCE_COUNT] resourcesMined;

  modifier ownerOnly() {
    require(msg.sender == owner);
    _;
  }

  modifier gameOnly() {
    require(msg.sender == game);
    _;
  }

  modifier gameOrOwnerOnly() {
    require(msg.sender == owner || msg.sender == game);
    _;
  }

  constructor(address setOwner, uint256 setSeed) public {
    game = msg.sender;
    owner = setOwner;
    seed = setSeed;
  }

  function setOwner(address newOwner) public gameOrOwnerOnly {
    owner = newOwner;
  }

  function setEquipment(uint256 newEquipment) public ownerOnly {

  }

  function setDeposit(uint256 newDeposit) public ownerOnly {

  }

  function stopMining() public ownerOnly {

  }

  function collect() public ownerOnly returns (uint256, uint256[RESOURCE_COUNT]) {

  }
}
