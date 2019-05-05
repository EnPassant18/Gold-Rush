pragma solidity ^0.4.24;

import "./Lode.sol";
import "./Gold.sol";
import "./Game.sol";
import "./Support/SafeMath.sol";

contract Player {

  using SafeMath for uint;
  string public constant contractName = 'Player';

  uint constant public RESOURCE_COUNT = 8;
  /*
    0: Iron
    1: Gas
    2: Aluminum
    3: Diamond
    4: Plutonium
    5: Platinum
    6: Antimatter
    7: Unobtanium
  */
  uint constant public EQUIPMENT_COUNT = 14;
  /*
    0: Bare Hands
    1: Cheese Grater
    2: Colander
    3: Giant Spork
    4: Plow
    5: Weed Cutter
    6: Jackhammer
    7: Earthmover
    8: Dredge
    9: Dynamite Factory
    10: Slave Army
    11: The Entire US Military
    12: The Death Star
    13: The Infinity Gauntlet
  */
  uint256 constant public DEPOSIT_COUNT = 4;
  /*
    0: Topsoil
    1: Subsoil
    2: Bedrock
    3: Ancient Alien Ruins
    4: None (mining is stopped)
  */

  // Crafting recipes for each equipment in terms of each resource
  uint[RESOURCE_COUNT][EQUIPMENT_COUNT] public RECIPES;
  // Called by constructor
  function initRecipes() private {
    RECIPES[0] = [0, 0, 0, 0, 0, 0, 0, 0];
    RECIPES[1] = [1, 0, 0, 0, 0, 0, 0, 0];
    RECIPES[2] = [3, 0, 0, 0, 0, 0, 0, 0];
    RECIPES[3] = [10, 0, 0, 0, 0, 0, 0, 0];
    RECIPES[4] = [25, 10, 0, 0, 0, 0, 0, 0];
    RECIPES[5] = [10, 1, 1, 0, 0, 0, 0, 0];
    RECIPES[6] = [20, 5, 5, 0, 0, 0, 0, 0];
    RECIPES[7] = [100, 10, 10, 0, 0, 0, 0, 0];
    RECIPES[8] = [400, 40, 0, 1, 0, 0, 0, 0];
    RECIPES[9] = [25, 0, 10, 0, 5, 0, 0, 0];
    RECIPES[10] = [150, 150, 0, 0, 0, 1, 0, 0];
    RECIPES[11] = [1000, 100, 100, 5, 5, 0, 0, 0];
    RECIPES[12] = [2500, 250, 250, 10, 10, 5, 1, 0];
    RECIPES[13] = [10000, 0, 0, 100, 25, 25, 10, 1];
  }

  address public owner; // Address that controls this player
  Game public game; // Reference to the master Game
  uint public goldBalance; // Amount of Gold this player owns
  Lode[] public lodes; // Array of all Lodes this player owns
  uint[RESOURCE_COUNT] public resources; // Array of the quantities of each resource this player owns
  uint[EQUIPMENT_COUNT] public equipmentOwned; // Array of the quantities of each equipment this player owns
  uint[EQUIPMENT_COUNT] public equipmentInUse; // Array of the quantities of each equipment this player is usings

  modifier ownerOnly() {
    require(msg.sender == owner);
    _;
  }

  constructor(address setOwner) public {
    game = Game(msg.sender);
    owner = setOwner;
    initRecipes();
  }

  // Changes the address that controls this player
  function setOwner(address newOwner) public ownerOnly {
    require(newOwner != address(0));
    owner = newOwner;
  }

  // Returns the number of lodes this player owns
  function lodesOwned() public view returns(uint) {
    return lodes.length;
  }

  // Changes the equipment being used on a given lode
  function lodeSetEquipment(uint lode, uint equipment) public ownerOnly {
    require(equipment < EQUIPMENT_COUNT, "Invalid equipment ID");
    lodeCollect(lode);
    uint currentEquipment = lodes[lode].equipment();
    if (currentEquipment != 0) {
      equipmentInUse[currentEquipment] = equipmentInUse[currentEquipment].sub(1);
    }
    if (equipment != 0) {
      require(equipmentOwned[equipment] > equipmentInUse[equipment]);
      equipmentInUse[equipment] = equipmentInUse[equipment].add(1);
    }
    lodes[lode].setEquipment(equipment);
  }

  // Changes the deposit being mined in a given lode
  function lodeSetDeposit(uint lode, uint deposit) public ownerOnly {
    require(deposit < DEPOSIT_COUNT, "Invalid deposit ID");
    lodeCollect(lode);
    Lode(lodes[lode]).setDeposit(deposit);
  }

  // Changes the equipment being used and deposit being mined for a given lode
  function lodeSetDepositAndEquipment(uint lode, uint equipment, uint deposit) public ownerOnly {
    if (deposit < lodes[lode].deposit()) {
      lodeSetDeposit(lode, deposit);
      lodeSetEquipment(lode, equipment);
    } else {
      lodeSetEquipment(lode, equipment);
      lodeSetDeposit(lode, deposit);
    }
  }

  // Stops mining on a given lode
  function lodeStopMining(uint lode) public ownerOnly {
    lodeCollect(lode);
    uint currentEquipment = lodes[lode].equipment();
    if (currentEquipment != 0) {
      equipmentInUse[currentEquipment] = equipmentInUse[currentEquipment].sub(1);
    }
    lodes[lode].stopMining();
  }

  // Collects resources mined from a given lode
  function lodeCollect(uint lode) public ownerOnly {
    (uint goldCollected, uint[RESOURCE_COUNT] memory resourcesCollected) = lodes[lode].collect();
    if (goldCollected == 0) return;
    goldBalance = goldBalance.add(goldCollected);
    for (uint i = 0; i < RESOURCE_COUNT; i++) {
      resources[i] = resources[i].add(resourcesCollected[i]);
    }
  }

  // Sells a given lode
  function sellLode(uint lode, uint price) public ownerOnly {
    game.sellLode(lodes[lode], price);
  }

  // Helper function to manage the lode array
  function _removeLode(address lode) private {
    uint i = 0;
    while (true) {
      if (address(lodes[i]) == lode) {
        delete lodes[i];
        break;
      }
      i++;
    }
    lodes.length = lodes.length.sub(1);
  }

  // Called by the Game when someone buys a lode this player is selling
  function sellLodeComplete(address lode, uint price) public {
    require(msg.sender == address(game));
    _removeLode(lode);
    goldBalance = goldBalance.add(price);
  }

  // Buys a Lode from another player
  function buyLode(address lode) public ownerOnly {
    uint price = game.buyLode(lode);
    goldBalance = goldBalance.sub(price);
    lodes.push(Lode(lode));
  }

  // Buys a new Lode from the Game
  function buyNewLode() public ownerOnly {
    address lode = game.buyNewLode();
    goldBalance = goldBalance.sub(game.newLodePrice());
    lodes.push(Lode(lode));
  }

  // Crafts a new equipment of the given type
  function craft(uint equipment) public ownerOnly {
    uint[RESOURCE_COUNT] storage recipe = RECIPES[equipment];
    for (uint i = 0; i < RESOURCE_COUNT; i++) {
      resources[i] = resources[i].sub(recipe[i]);
    }
    equipmentOwned[equipment] = equipmentOwned[equipment].add(1);
  }

  // Buys Gold from the Game in exchange for Ether
  function buyGold() public payable ownerOnly {
    goldBalance = goldBalance.add(game.buyGold.value(msg.value)());
  }

  // To receive change from buyGold
  function () public payable {}
}
