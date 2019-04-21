pragma solidity ^0.4.24;

import "./Game.sol";
import "./Support/SafeMath.sol";

contract Lode {

  string public constant contractName = "Lode";

  address public owner;
  uint256 private seed;
  address public game;
  uint256 constant public RESOURCE_COUNT = 8;
  uint256 constant public EQUIPMENT_COUNT = 14;
  uint256 constant public DEPOSIT_COUNT = 4;
  uint256 public deposit = 0; // Zero means we're not mining
  uint256 public equipment = 0; // Zero means we're not mining

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
    require(newEquipment <= EQUIPMENT_COUNT, "Invalid equipment ID");
    equipment = newEquipment;
  }

  function setDeposit(uint256 newDeposit) public ownerOnly {
    require(newDeposit <= DEPOSIT_COUNT, "Invalid deposit ID");
    // TODO: make sure deposit is not buried
    deposit = newDeposit;
  }

  function stopMining() public ownerOnly {
    equipment = 0;
    deposit = 0;
  }

  function collect() public ownerOnly returns (uint256, uint256[RESOURCE_COUNT]) {
    // TODO: figure out how many yields occurred since last call,
    // calculate the gold and resources mined, and return them.
    // Also call Game(game).lodeMint(owner, quantity) with the quantity of Gold mined
    // to mint new gold and give it to the player.
  }
}
