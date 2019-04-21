pragma solidity ^0.4.24;

import "./Support/SafeMath.sol";

contract Random {

  using SafeMath for uint256;

  uint256 private seed = 0;

  function random() internal returns(uint256) {
    uint256 out = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, seed))) % 100;
    seed.add(1);
    return out;
  }

  function generate() external returns (uint256) {
    return random();
  }
}
