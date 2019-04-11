pragma solidity ^0.4.24;

import "./Tokens/ERC721.sol";
import "./BearBucks.sol";
import "./Player.sol";

contract Game is ERC721 {

    string public constant _contractName = 'Game'; // For testing.
    uint256 public _goldPrice;
    uint256 public _loadPrice;
    address public _owner;
    Gold public _GoldContract;
    //mapping address to booleans.
    // for register 

    constructor(
        uint256 goldPrice,
        uint256 loadPrice
    ) public {

        _GoldContract = new Gold();
        _GoldContract.setMinter(address(this));
        _owner = msg.sender;
        _goldPrice = goldPrice;
        _loadPrice = loadPrice;
    }


    function register() public {
        player = Player(); 
        /**
        I create the player contract with them as the owner.
        then return the address of that contract.
        Thhen put that address in a map. That way I know this contract is real.
        */
        
    }


    
    function goldPrice() public view {
        _goldPrice
    }

    function changeGoldPrice public {

    }


    function buyGold() public {
        
    }

    function sellLode(address lode, uint256 price) public {

    }


    function setNewLodePrice(uint256 newPrice) public {
        _loadPrice = newPrice;
    }

    function setNewGoldPrice(uint256 )

}