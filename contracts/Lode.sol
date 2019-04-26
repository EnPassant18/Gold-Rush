pragma solidity ^0.4.24;

import "./Game.sol";
import "./Random.sol";
import "./Support/SafeMath.sol";

contract Lode {

  using SafeMath for uint256;

  string public constant contractName = "Lode";

  address public owner;
  address public game;
  uint256 constant public RESOURCE_COUNT = 8;
  uint256 constant public EQUIPMENT_COUNT = 14;
  uint256 constant public DEPOSIT_COUNT = 4;
  uint256[DEPOSIT_COUNT] public yieldsPerDeposit = [250, 500, 1000, 150];
  uint256[DEPOSIT_COUNT][RESOURCE_COUNT] distributions; // Each row must sum to 2^256
  uint256 public deposit = 0; // Zero means we're not mining
  uint256 public equipment = 0; // Zero represents topsoil
  uint256 public lastCollect; // Block when collect was last called
  Random private random;

  struct Equipment {
    uint256 maxDeposit;
    uint256 blocksPerYield;
  }
  Equipment[EQUIPMENT_COUNT] allEquipment;

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
  }

  function setOwner(address newOwner) public gameOrOwnerOnly {
    owner = newOwner;
  }

  function setEquipment(uint256 newEquipment) public ownerOnly {
    require(newEquipment <= EQUIPMENT_COUNT, "Invalid equipment ID");
    require(lastCollect == block.number, "You must collect before changing equipment");
    require(allEquipment[newEquipment].maxDeposit >= deposit, "Invalid equipment for current target deposit");
    equipment = newEquipment;
  }

  function setDeposit(uint256 newDeposit) public ownerOnly {
    require(newDeposit < DEPOSIT_COUNT, "Invalid deposit ID");
    require(lastCollect == block.number, "You must collect before changing deposit");
    require(allEquipment[equipment].maxDeposit >= newDeposit, "Invalid target deposit for current equipment");
    deposit = newDeposit;
  }

  function stopMining() public ownerOnly {
    require(lastCollect == block.number, "You must collect before halting");
    equipment = 0;
  }

  function collect() public ownerOnly returns (uint256, uint256[RESOURCE_COUNT]) {
    uint256[RESOURCE_COUNT] memory resourcesMined;
    if (equipment == 0) {
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
      uint256 randomValue = random.random();
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
