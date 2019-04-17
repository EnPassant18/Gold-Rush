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
    /*Stores address of the Gold contract instantiating this contract*/
    address public _GameContract;
    /* Stores address of a minter address if one is added. */

    constructor() public {
      _GameContract = msg.sender;
    }

    modifier onlyGameContract() {
        require(msg.sender == _GameContract, "msg.sender is not Game contract.");
        _;
    }
    
    //When you want to buy gold, the Game contract mints to a Player address
    function mint(address to, uint256 amount) public onlyGoldTokenContract {
        _mint(to, amount);
    }
    //When you want to remove gold from a player, the Game contract calls burn
    function burn(address from, uint256 amount) public onlyGoldTokenContract {
      _burn(from, amount);
    }

 }
