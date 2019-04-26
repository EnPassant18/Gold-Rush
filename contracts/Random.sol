pragma solidity ^0.4.24;

import "./Support/SafeMath.sol";

contract Random {

  using SafeMath for uint256;

  uint256 private seed = 0;

  function random() public returns(uint256) {
    uint256 out = uint256(keccak256(abi.encodePacked(blockhash(block.number), msg.sender, seed)));
    seed.add(1);
    return out;
  }
}
