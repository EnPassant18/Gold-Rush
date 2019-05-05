pragma solidity ^0.4.24;

import "./Game.sol";
import "./Random.sol";
import "./Support/SafeMath.sol";

contract Lode {

  using SafeMath for uint256;
  string public constant contractName = "Lode";

  uint256 constant public RESOURCE_COUNT = 8;
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
  uint256 constant public EQUIPMENT_COUNT = 14;
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
    11: The US Military
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

  address public owner; // Address that controls this Lode
  address public game; // Reference to the master Game
  uint256 public deposit = 4; // Deposit being mined
  uint256 public equipment = 0; // Equipment being used
  uint256 public lastCollect; // Block when collect was last called
  Random private random;

  // Number of yields that can be mined from each deposit
  uint256[DEPOSIT_COUNT] public yieldsPerDeposit = [250, 500, 1000, 50];

  struct Equipment {
    uint256 maxDeposit;
    uint256 blocksPerYield;
  }
  // The specifications of each equipment type
  Equipment[EQUIPMENT_COUNT] public allEquipment;
  // Called by constructor
  // There are about 6500 blocks per day
  function initAllEquipment() private {
    allEquipment[0].blocksPerYield = 6500;
    allEquipment[1].blocksPerYield = 3250;
    allEquipment[2].blocksPerYield = 2167;
    allEquipment[3].blocksPerYield = 1625;
    allEquipment[4].blocksPerYield = 1300;
    allEquipment[5].blocksPerYield = 2167;
    allEquipment[6].blocksPerYield = 1300;
    allEquipment[7].blocksPerYield = 813;
    allEquipment[8].blocksPerYield = 1300;
    allEquipment[9].blocksPerYield = 433;
    allEquipment[10].blocksPerYield = 217;
    allEquipment[11].blocksPerYield = 100;
    allEquipment[12].blocksPerYield = 10;
    allEquipment[13].blocksPerYield = 1;
    allEquipment[0].maxDeposit = 0;
    allEquipment[1].maxDeposit = 0;
    allEquipment[2].maxDeposit = 0;
    allEquipment[3].maxDeposit = 0;
    allEquipment[4].maxDeposit = 1;
    allEquipment[5].maxDeposit = 1;
    allEquipment[6].maxDeposit = 1;
    allEquipment[7].maxDeposit = 1;
    allEquipment[8].maxDeposit = 2;
    allEquipment[9].maxDeposit = 2;
    allEquipment[10].maxDeposit = 2;
    allEquipment[11].maxDeposit = 3;
    allEquipment[12].maxDeposit = 3;
    allEquipment[13].maxDeposit = 3;
  }

  // The probability (x1000) with which each resource occurs in each deposit
  uint256[RESOURCE_COUNT][DEPOSIT_COUNT] public distributions = [
    [800, 200, 0, 0, 0, 0, 0, 0],
    [650, 90, 250, 10, 0, 0, 0, 0],
    [450, 0, 250, 0, 200, 9, 1, 0],
    [0, 0, 0, 200, 600, 190, 9, 1]
  ];

  modifier ownerOnly() {
    require(msg.sender == owner);
    _;
  }

  modifier gameOrOwnerOnly() {
    require(msg.sender == owner || msg.sender == game);
    _;
  }

  constructor(address setOwner) public {
    game = msg.sender;
    owner = setOwner;
    random = new Random();
    initAllEquipment();
  }

  // Changes the address that controls this Lode
  function setOwner(address newOwner) public gameOrOwnerOnly {
    owner = newOwner;
  }

  // Changes the equipment being used to mine this Lode
  function setEquipment(uint256 newEquipment) public ownerOnly {
    require(newEquipment < EQUIPMENT_COUNT, "Invalid equipment ID");
    require(lastCollect == block.number, "You must collect before changing equipment");
    require(allEquipment[newEquipment].maxDeposit >= deposit, "Invalid equipment for current target deposit");
    equipment = newEquipment;
  }

  // Changes the deposit of this Lode being mined
  function setDeposit(uint256 newDeposit) public ownerOnly {
    require(newDeposit < DEPOSIT_COUNT, "Invalid deposit ID");
    require(lastCollect == block.number, "You must collect before changing deposit");
    require(allEquipment[equipment].maxDeposit >= newDeposit, "Invalid target deposit for current equipment");
    deposit = newDeposit;
  }

  // Stops mining on this Lode
  function stopMining() public ownerOnly {
    require(lastCollect == block.number, "You must collect before halting");
    deposit = 4;
  }

  /* Returns the quantity of Gold and resources (as an array) mined since the last
  call of this function. Calls game.lodeMint to mint Gold for the collector. */
  function collect() public ownerOnly returns (uint256, uint256[RESOURCE_COUNT]) {
    uint256[RESOURCE_COUNT] memory resourcesMined;
    if (deposit == 4) {
      lastCollect = block.number;
      return (0, resourcesMined);
    }
    uint256 yields = block.number.sub(lastCollect).div(allEquipment[equipment].blocksPerYield);
    if (yields > yieldsPerDeposit[deposit]) {
      yields = yieldsPerDeposit[deposit];
    }
    yieldsPerDeposit[deposit] = yieldsPerDeposit[deposit].sub(yields);
    lastCollect = block.number;
    Game(game).lodeMint(owner, yields);
    for (uint256 i = 0; i < yields; i++) {
      uint256 randomValue = random.random().mod(1000);
      for (uint256 resource = 0; resource < RESOURCE_COUNT; resource++) {
        if (randomValue < distributions[deposit][resource]) {
          resourcesMined[resource] = resourcesMined[resource].add(1);
          break;
        }
        randomValue = randomValue.sub(distributions[deposit][resource]);
      }
    }
    return (yields, resourcesMined);
  }
}
