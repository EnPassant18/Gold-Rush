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
  bool private uncovered = false;
  uint256 private uncoveredTracker = 0;

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
    require(newEquipment > 0, "Setting equipment to 0 will halt the mining.");
    require(newEquipment <= EQUIPMENT_COUNT, "Invalid equipment ID");
    equipment = newEquipment;
  }

  function setDeposit(uint256 newDeposit) public ownerOnly {
    require(newDeposit > 0, "Setting deposit to 0 will halt the mining.");
    require(newDeposit <= DEPOSIT_COUNT, "Invalid deposit ID");
    //make sure deposit is not buried
    //using simple arithmetic to keep track of prior lode
    if !uncovered:
      if newDeposit == 1:
        uncoveredTracker.add(newDeposit);
      else if newDeposit == 2:
        require(uncoveredTracker == 1, "To mine for Subsoil [id: 2], you need to mine for Topsoil[id:1].")
        uncoveredTracker.add(newDeposit);
      else if newDeposit == 3:
          require(uncoveredTracker == 3, "To mine for BedRock, you need to mine for Topsoil[id:1] and Subsoil [id: 2] first.")
          uncoveredTracker.add(newDeposit);
      else:
          require(uncoveredTracker == 6, "To mine for Ancient Alient Ruins, you need to mine for BedRock, Subsoil, and Topsoil.")
          uncovered = true;

    deposit = newDeposit;

  }

  function stopMining() public ownerOnly {
    equipment = 0;
    deposit = 0;
    uncovered = false;
    uncoveredTracker = 0;
  }

  /*
  The equipment has to be able to mine that deposit
  And the deposit must not be buried */
  function collect() public ownerOnly returns (uint256, uint256[RESOURCE_COUNT]) {
    require(deposit > 0, "This Lode is not mining because no deposit is set."");
    require(equipment > 0, "This Lode is not mining because no equipment is set.");

    //return
    // TODO: figure out how many yields occurred since last call,
    // calculate the gold and resources mined, and return them.
    // Also call Game(game).lodeMint(owner, quantity) with the quantity of Gold mined
    // to mint new gold and give it to the player.
  }
}
