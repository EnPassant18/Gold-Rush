pragma solidity ^0.4.24;

import "./Lode.sol";
import "./Gold.sol";
import "./Game.sol";
import "./Support/SafeMath.sol";

contract Player {

  using SafeMath for uint;
  string public constant contractName = 'Player';

  uint constant public RESOURCE_COUNT = 8;
  uint constant public EQUIPMENT_COUNT = 14;
  uint[RESOURCE_COUNT][EQUIPMENT_COUNT] public RECIPES;

  address public owner;
  Game public game;
  uint public goldBalance;
  Lode[] public lodes; // Array of all Lodes this player owns
  uint[RESOURCE_COUNT] public resources; // Array of the quantities of each resource this player owns
  uint[EQUIPMENT_COUNT] public equipmentOwned; // Array of the quantities of each equipment this player owns
  uint[EQUIPMENT_COUNT] public equipmentInUse; // Array of the quantities of each equipment this player is using

  event Log(uint value);

  modifier ownerOnly() {
    require(msg.sender == owner);
    _;
  }

  constructor(address setOwner) public {
    game = Game(msg.sender);
    owner = setOwner;
  }

  function setOwner(address newOwner) public ownerOnly {
    owner = newOwner;
  }

  function lodesOwned() public view returns(uint) {
    return lodes.length;
  }

  function lodeSetEquipment(uint lode, uint equipment) public ownerOnly {
    lodeCollect(lode);
    require(equipmentOwned[equipment].sub(equipmentInUse[equipment]) > 0);
    equipmentInUse[lodes[lode].equipment()] = equipmentInUse[lodes[lode].equipment()].sub(1);
    equipmentInUse[equipment] = equipmentInUse[equipment].add(1);
    lodes[lode].setEquipment(equipment);
  }

  function lodeSetDeposit(uint lode, uint deposit) public ownerOnly {
    lodeCollect(lode);
    lodes[lode].setDeposit(deposit);
  }

  function lodeSetDepositAndEquipment(uint lode, uint equipment, uint deposit) public ownerOnly {
    lodeCollect(lode);
    if (deposit < lodes[lode].deposit()) {
      lodeSetDeposit(lode, deposit);
      lodeSetEquipment(lode, equipment);
    } else {
      lodeSetEquipment(lode, equipment);
      lodeSetDeposit(lode, deposit);
    }
  }

  function lodeStopMining(uint lode) public ownerOnly {
    equipmentInUse[lodes[lode].equipment()] = equipmentInUse[lodes[lode].equipment()].sub(1);
    lodes[lode].stopMining();
  }

  function lodeCollect(uint lode) public ownerOnly {
    (uint goldCollected, uint[RESOURCE_COUNT] memory resourcesCollected) = lodes[lode].collect();
    if (goldBalance == 0) return;
    goldBalance = goldBalance.add(goldCollected);
    for (uint i = 0; i < RESOURCE_COUNT; i++) {
      resources[i] = resources[i].add(resourcesCollected[i]);
    }
  }

  function sellLode(uint lode, uint price) public ownerOnly {
    game.sellLode(lodes[lode], price);
  }

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
    // TODO: move elements after deletion
  }

  function sellLodeComplete(address lode, uint price) public {
    require(msg.sender == address(game));
    _removeLode(lode);
    goldBalance = goldBalance.add(price);
  }

  function buyLode(address lode) public ownerOnly {
    uint price = game.buyLode(lode);
    goldBalance = goldBalance.sub(price);
    lodes.push(Lode(lode));
  }

  function buyNewLode() public ownerOnly {
    address lode = game.buyNewLode();
    goldBalance = goldBalance.sub(game.newLodePrice());
    lodes.push(Lode(lode));
  }

  function craft(uint equipment) public ownerOnly {
    uint[RESOURCE_COUNT] storage recipe = RECIPES[equipment];
    for (uint i = 0; i < RESOURCE_COUNT; i++) {
      resources[i] = resources[i].sub(recipe[i]);
    }
    equipmentOwned[equipment] = equipmentOwned[equipment].add(1);
  }

  function buyGold() public payable ownerOnly {
    goldBalance = goldBalance.add(game.buyGold.value(msg.value)());
  }

  function () public payable {}
}