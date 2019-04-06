pragma solidity ^0.4.24;

import "./Lode.sol";
import "./Gold.sol";
import "./Game.sol";

contract Player {
  using SafeMath for uint;

  uint constant public RESOURCE_COUNT = 8;
  uint constant public MACHINE_COUNT = 14;
  uint[MACHINE_COUNT][RESOURCE_COUNT] constant public RECIPES; // TODO: initialize

  address public owner;
  Game public game;
  uint public goldBalance;
  Lode[] public lodes; // Array of all Lodes this player owns
  uint[RESOURCE_COUNT] public resources; // Array of the quantities of each resource this player owns
  uint[MACHINE_COUNT] public machines; // Array of the quantities of each machine this player owns
  uint[MACHINE_COUNT] public machinesInUse; // Array of the quantities of each machine this player is using

  modifier ownerOnly() {
    require(msg.sender == owner);
  }

  constructor(address setOwner) public {
    game = msg.sender;
    owner = setOwner;
  }

  function lodeSetMachine(uint lode, uint machine) public ownerOnly {
    require(machines[machine].sub(machinesInUse[machine]) > 0);
    machinesInUse[lodes[lode].machine] = machinesInUse[lodes[lode].machine].sub(1);
    machinesInUse[machine] = machinesInUse[machine].add(1);
    lodes[lode].setMachine(machine);
  }

  function lodeSetDeposit(uint lode, uint deposit) public ownerOnly {
    lodes[lode].setDeposit(deposit);
  }

  function lodeStopMining(uint lode) public ownerOnly {
    machinesInUse[lodes[Lode].machine] = machinesInUse[lodes[Lode].machine].sub(1);
    lode.stopMining();
  }

  function lodeCollect(uint lode) public ownerOnly {
    (uint goldCollected, uint resourcesCollected) = lodes[lode].collect();
    goldBalance = goldBalance.add(goldCollected);
    for (uint i = 0; i < RESOURCE_COUNT; i++) {
      resources[i] = resources[i].add(resourcesCollected[i]);
    }
  }

  function sellLode(uint lode, uint price) public ownerOnly {
    game.sellLode(lodes[lode], price);
  }

  function _removeLode(address lode) private {
    i = 0;
    while (true) {
      if (address(lodes[i]) == lode) {
        delete lodes[i];
        break;
      }
      i++;
    }
    // TODO: move elements after deletion
  }

  function sellLodeComplete(address lode, uint price) public {
    require(msg.sender == game);
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
    goldBalance = goldBalance.sub(game.newLodePrice);
    lodes.push(Lode(lode));
  }

  function craft(uint machine) public ownerOnly {
    uint[RESOURCE_COUNT] recipe = RECIPES[machine];
    for (uint i = 0; i < RESOURCE_COUNT; i++) {
      resources[i] = resources[i].sub(recipe[i]);
    }
    machines[machine] = machines[machine].add(1);
  }

  function buyGold() public payable ownerOnly {
    goldBalance = goldBalance.add(game.buyGold.call.value(msg.value)());
  }
}