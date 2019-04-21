pragma solidity ^0.4.24;

import "./Tokens/ERC20.sol";
import "./Support/SafeMath.sol";

/**
@title Gold is an ERC20 token

Players control their own gold, and the game registers these players.
The game will access the exchange between Gold, our ERC20 token,
and Lode, our ERC-721 token
 */


 contract Gold is ERC20 {

    string public constant contractName = 'Gold';

    address public GameContract;

    constructor() public {
      GameContract = msg.sender;
    }

    modifier onlyGameContract() {
      require(msg.sender == GameContract, "Caller is not Game contract");
      _;
    }

    function mint(address to, uint256 amount) public onlyGameContract {
      _mint(to, amount);
    }

    function burn(address from, uint256 amount) public onlyGameContract {
      _burn(from, amount);
    }
 }
