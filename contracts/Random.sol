pragma solidity ^0.4.24;


contract Random {

  using SafeMath for uint256;

  uint256 private seed;

  /*
  Generates a random number between 0-100;
  */
  function random() internal returns(uint256) {
    uint256 random = uint256(keccak256(block.timestamp, msg.sender, seed)) % 100;
    seed.add(1);

    return random;
  }

  function generate() external view returns (uint256) {
    return random();
  }
}
