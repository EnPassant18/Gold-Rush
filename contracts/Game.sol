pragma solidity ^0.4.24;

import "./Player.sol";
import "./Gold.sol";
import "./Lode.sol";
import "./Support/SafeMath.sol";

contract Game  {

  using SafeMath for uint256;
  string public constant contractName = 'Game';

  address public moderator;
  address public wallet;
  uint256 public weiCollected;
  mapping(address => bool) public registration;
  mapping(address => bool) public lodeRegistration;
  Gold public GoldContract;

  struct LodeForSale {
    uint256 price;
    address seller;
  }

  uint256 public goldPrice; // in Wei
  uint256 public newLodePrice; // in Gold
  mapping(address => LodeForSale) public lodesForSale;

  event Register(address player);
  event Log(uint value);

  modifier isModerator() {
    require(msg.sender == moderator, "Caller must be the moderator");
    _;
  }

  modifier isRegistered {
    require(registration[msg.sender], "Caller must be registered");
    _;
  }

  constructor(uint256 setGoldPrice, uint256 setLodePrice, address setModerator, address setWallet) public {
      require(setGoldPrice > 0);
      require(setLodePrice > 0);
      require(setModerator != address(0));
      require(setWallet != address(0));
      GoldContract = new Gold();
      goldPrice = setGoldPrice;
      newLodePrice = setLodePrice;
      moderator = setModerator;
      wallet = setWallet;
  }

  // Instantiates a new Player and registers it.
  // Sets the caller as the Player's owner. Returns the address of the Player.
  function register() public returns(address) {
      address playerAddress = new Player(msg.sender);
      registration[playerAddress] = true;
      emit Register(playerAddress);
      return playerAddress;
  }

  // Changes who the moderator is
  function setModerator(address newModerator) public isModerator {
    require(newModerator != address(0));
    moderator = newModerator;
  }

  /**
  * Sells a new Lode in exchange for Gold at the newLodePrice.
  * Returns the address of the Lode.
  */
  function buyNewLode() public isRegistered returns(address) {
    GoldContract.burn(msg.sender, newLodePrice);
    address newLodeAddress = address(new Lode(msg.sender));
    lodeRegistration[newLodeAddress] = true;
    return newLodeAddress;
  }

  /**
  * Sells Gold in exchange for Ether to Players.
  * Returns amount of Gold bought.
  */
  function buyGold() public payable isRegistered returns(uint256) {
    uint256 goldBought = msg.value.div(goldPrice);
    GoldContract.mint(msg.sender, goldBought);
    uint256 change = msg.value.mod(goldPrice);
    uint256 weiSpent = msg.value - change;
    weiCollected = weiCollected.add(weiSpent);
    msg.sender.transfer(change);
    return goldBought;
  }

  /**
  * Allows players to propose sale of a Lode for a given price.
  * @param lode address of the Lode struct that you want to place for sell
  * @param price quantity of tokens the lode is being placed up for sale for in terms of Gold.
  */
  function sellLode(address lode, uint256 price) public isRegistered {
    require(lodeRegistration[lode]);
    require(Lode(lode).owner() == msg.sender, "Player must own the lode they're selling");
    lodesForSale[lode] = LodeForSale(price, msg.sender);
  }

  /**
  * Buys a lode that is for sale.
  * @param lode address of the Lode struct that you want to buyGold
  */
  function buyLode(address lode) public isRegistered returns(uint256) {
    require(lodeRegistration[lode]);
    address seller = lodesForSale[lode].seller;
    address buyer = msg.sender;
    uint256 price = lodesForSale[lode].price;
    require(seller != address(0), "Lode must be for sale");
    delete lodesForSale[lode];
    GoldContract.burn(buyer, price);
    GoldContract.mint(seller, price);
    Lode(lode).setOwner(buyer);
    Player(seller).sellLodeComplete(lode, price);
    return price;
  }

  // Changes the new Lode price
  function setNewLodePrice(uint256 price) isModerator public {
    require(price > 0);
    newLodePrice = price;
  }

  // Changes the Gold price
  function setNewGoldPrice(uint256 price) isModerator public {
    require(price > 0);
    goldPrice = price;
  }

  function lodeMint(address miner, uint256 quantity) public {
    require(lodeRegistration[msg.sender], "Caller must be a valid Lode");
    GoldContract.mint(miner, quantity);
  }
}
