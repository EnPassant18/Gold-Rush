pragma solidity ^0.4.24;

import "./Tokens/ERC721.sol";
import "./Player.sol";
import "./Gold.sol";
import "./Game.sol";
import "./Random.sol";
import "./Lode.sol";

/*

Game Missive:
Players control their own gold, and the game registers these players.
The game will access the exchange between Gold, our ERC20 token,
and Lode, our ERC-721 token
*/


contract Game is ERC721 {
    using SafeMath for uint256;

    string public constant _contractName = 'Game';



    address private _wallet;

    //Price of Gold being sold in wei.
    uint256 public newGoldPrice;
    //Price of Lode being sold in Gold.
    uint256 public newLodePrice;
    uint256 public _weiCollected;

    mapping(address => bool) private _registration;
    mapping(address => bool) private _moderators;
    mapping(address => uint256) private _lodesForSale;


    Gold private _GoldContract;
    Lode private _LodeContract;
    Random private _RandomGenerator;

    constructor(uint256 goldPrice , uint256 lodePrice, address wallet) public {
        _GoldContract = new Gold();
        _LodeContract = new Lode();
        _RandomGenerator = new Random();

        require(goldPrice > 0);
        require(lodePrice > 0);
        newGoldPrice = goldPrice;
        newLodePrice = lodePrice;
        _wallet = wallet;
    }

    /* Instantiates new Player and registers it.
    /*
    * returns address of Player.
    */
    function register() public returns(address) {
        Player player = new Player(msg.sender);
        address playerAddress = address(player);
        _registration[playerAddress] = true;
        return playerAddress;
    }


    function unregister() public isRegistered(msg.sender){
      _registration[msg.sender] = false;
    }

    modifier isRegistered(address player) {
      require(_registration[player], "msg.sender is not registered.");
      _;
    }
    /*
    You should only be able to make a registerd player a moderator.
    */
    function addModerator(address moderator) public isRegistered(msg.sender) {
      _moderators[moderator] = true;
    }

    modifier isModerator(address player) {
      require(_moderators[player], "msg.sender is not a moderator.");
      _;
    }

    /**
    * Given that a player has enough gold to mint a new lode at newLodePrice,
    * Game can sell a random Lode in exchange for Gold at the newLodePrice.
    * Keep in mind that newLodePrice is in terms of Gold.
    * Gold is burned in order to get a Lode. Game does not need to collect
    * the Gold sent because it is merely an intermediary for Gold, not a collector.
    *
    * returns address lode struct created
    */
    function buyNewLode() public isRegistered(msg.sender) returns(address){
      address player = msg.sender;
      require(_GoldContract.balanceOf(player) >= newLodePrice,
        "You do not have enough gold. Call buyGold() to get more.");
      _GoldContract.takeAwayGold(player, newLodePrice);
      uint256 rand = _RandomGenerator.generate();
      return _LodeContract.newLode(player, rand);
    }


    /**
    * Gives Gold in exchange for Ether to Players.
    *
    *
    * returns amount of Gold bought.
    */
    function buyGold() public payable isRegistered(msg.sender) returns(uint256) {
      address player = msg.sender;
      uint256 weiGiven = msg.value;
      uint256 numGoldTokensBought = _convertToGoldTokens(weiGiven);
      require(numGoldTokensBought > 0, "Not enough ether sent to afford Gold.");
      //Division does not do remainder. We want to be able to refund unspent wei
      uint256 weiSpent = numGoldTokensBought.mul(newGoldPrice);

      _weiCollected.add(weiSpent);
      _GoldContract.giveGold(beneficiary, numGoldTokensBought);

      _giveChangeAndKeepEther(weiGiven, weiSpent);
      return numGoldTokensBought;
    }

    /**
    * Allows players to propose sale of a Lode for a given price.
    * @param lode address of the Lode struct that you want to place for sell
    * @price quantity of tokens the lode is being placed up for sale for in terms of Gold.
    */
    function sellLode(address lode, uint256 price) public isRegistered(msg.sender) {
      require(lode != address(0));
      require(_LodeContract.ownerOf(lode) == msg.sender);
      //Lode Contract becomes an operator.
      _LodeContract.approve(address(this), lode.tokenID);
      _GoldContract.giveGold(msg.sender, price);
      _lodesForSale[lode] = price;
      owner.sellLodeComplete(lode, price);
    }

    /**
    * Buys a lode that is for sale.
    * @param lode address of the Lode struct that you want to bu
    *
    */
    function buyLode(address lode) public isRegistered(msg.sender) {
      require(lode != address(0));
      //You can't directly find out if any key exists in a mapping, ever, because they all exist.
      //therefore. it is best to use approve() / getApproved() to maintain the "state" of whether
      // it is sold or not.
      require(_LodeContract.getApproved(lode.tokenID) == address(this),
        "This lode is not up for sale.");
      address buyer = msg.sender;
      uint256 price = _lodesForSale[lode];
      require(_GoldContract.balanceOf(buyer) >= price,
        "You need more Gold to afford this Lode. Please use buyGold() to get more Gold for this Lode.");

      //Remove Gold from the buyers balance and make them the owner of the lode that
      //was for sale. Unapprove by setting approval to 0, so the Lode is no longer posted for sale.
      _GoldContract.takeAwayGold(buyer, price);
      _LodeContract.transferFrom(owner, buyer, lode.tokenID);
      _LodeContract.approve(address(0), lode.tokenID);
      return price;
    }

  /**
  * Uses SafeMath to convert ether to Gold based on the established Gold price.
  * Only returns unsigned integer. No floating points.
  * @param weiGiven how much ether retrieved from the caller.
  *
  */
  function _convertToGoldTokens(uint256 weiGiven) internal returns(uint256) {
    require(weiGiven >= newGoldPrice);
    return weiGiven.div(newGoldPrice);
  }

  /**
  * Returns unspent ether and places ether spent in Game's wallet
  * @param weiGiven how much ether retrieved from the caller
  */
  function _giveChangeAndKeepEther(uint256 weiGiven, uint256 weiSpent) internal {
    require(weiGiven >= weiSpent);
    if (weiGiven > weiSpent) {
      uint256 change = weiGiven.sub(weiSpent);
      msg.sender.transfer(change)
    }

    _wallet.transfer(weiSpent);
  }

  function setNewLodePrice(uint256 price) isModerator(msg.sender) {
    newLodePrice = price;
  }

  function setNewGoldPrice(uint256 price) isModerator(msg.sender) {
    newGoldPrice = price;
  }

}
