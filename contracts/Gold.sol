pragma solidity ^0.4.24;

import "./Tokens/ERC20.sol";

/**
@title Gold is an ERC20 token

Players control their own gold, and the game registers these players.
The game will access the exchange between Gold, our ERC20 token,
and Lode, our ERC-721 token
 */


 contract Gold is ERC20 {

    string public constant contractName = 'Gold';
    address public contractOwner;
    address public minter;
 

    constructor() public {
        contractOwner = msg.sender;
    }

    modifier onlyGoldTokenContract() {
        require(msg.sender == contractOwner, "Caller does not own this contract.");
        _;
    }


  /**
   * Updates the minter address.
   * @param newMinter The address of the new minter.
   */
  function setMinter(address newMinter) public onlyGoldTokenContract {
    minter = newMinter;
  }


    //Game will want to be able to mint accounts
    function mint( address to, uint256 amount) public onlyGoldTokenContract() {
        _mint(to, amount);
    }

 }