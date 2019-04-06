pragma solidity ^0.4.24;

import "../Support/IERC721.sol";
import "../Support/SafeMath.sol";

/**
* This contract implements the ERC721 token standard. In addition to the
* functions specified by the IERC721 interface, it has five internal functions
* (you're welcome to add more if you wish). Two of the below functions,
* _transferFrom and _mint, have been left for you to fill in. As with the ERC20
* contract, you may copy the solutions verbatim from the OpenZeppelin-Solidity
* repository, but we recommend that you try it yourself first.
* https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/token/ERC721/ERC721.sol
*/
contract ERC721 is IERC721 {
  using SafeMath for uint256;

  /* Stores the owner of each token. */
  mapping (uint256 => address) private _tokenOwner;

  /* Stores the approved address (if one exists) for each token. */
  mapping (uint256 => address) private _tokenApprovals;

  /* Stores the number of tokens owned by each address. */
  mapping (address => uint256) private _ownedTokensCount;

  /* Stores the operator approvals for each address. */
  mapping (address => mapping (address => bool)) private _operatorApprovals;

  /**
   * @param owner The address to query the balance of.
   * @return The amount of tokens owned by the passed address as a uint256.
   */
  function balanceOf(address owner) public view returns (uint256) {
    require(owner != address(0));
    return _ownedTokensCount[owner];
  }

  /**
   * @param tokenId uint256 ID of the token to query the owner of.
   * @return The address that owns the specified token.
   */
  function ownerOf(uint256 tokenId) public view returns (address) {
    return _tokenOwner[tokenId];
  }

  /**
   * Approves another address to transfer the given token ID.
   * There can only be one approved address per token at a given time.
   * Can only be called by the token owner or an approved operator.
   * @param to The address to be approved for the given token ID.
   * @param tokenId uint256 ID of the token.
   */
  function approve(address to, uint256 tokenId) public {
    address owner = ownerOf(tokenId);
    require(to != owner);
    require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

    _tokenApprovals[tokenId] = to;
    emit Approval(owner, to, tokenId);
  }

  /**
   * @param tokenId uint256 ID of the token to query the approval of.
   * @return The approved address, or zero if no address is approved.
   */
  function getApproved(uint256 tokenId) public view returns (address) {
    return _tokenApprovals[tokenId];
  }

  /**
   * Sets or unsets operators. An operator is an address allowed to transfer
   * all tokens of the sender on their behalf.
   * @param to The address to add or remove as an operator.
   * @param approved A bool representing whether the address is an operator.
   */
  function setApprovalForAll(address to, bool approved) public {
    require(to != msg.sender);
    _operatorApprovals[msg.sender][to] = approved;
    emit ApprovalForAll(msg.sender, to, approved);
  }

  /**
   * Determines whether an address is set as an operator.
   * @param owner The address which may have the specified operator.
   * @param operator The address which may be an operator for owner.
   * @return A bool representing whether owner has the specified operator.
   */
  function isApprovedForAll(address owner, address operator)
    public view returns (bool)
  {
    return _operatorApprovals[owner][operator];
  }

  /**
    * @dev Returns whether the given spender can transfer a given token ID
    * @param spender address of the spender to query
    * @param tokenId uint256 ID of the token to be transferred
    * @return bool whether the msg.sender is approved for the given token ID,
    *    is an operator of the owner, or is the owner of the token
    */
  function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
    address owner = ownerOf(tokenId);
    // Disable solium check because of
    // https://github.com/duaraghav8/Solium/issues/175
    // solium-disable-next-line operator-whitespace
    return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
  }

  /**
   * Transfers the ownership of a given token to another address.
   * @param from The address of the token's current owner.
   * @param to The address to receive ownership of the token.
   * @param tokenId uint256 ID of the token to be transfered.
  */
  function transferFrom(address from, address to, uint256 tokenId) public {
    require(_isApprovedOrOwner(msg.sender, tokenId));
    require(to != address(0));

    _clearApproval(from, tokenId);
    _removeTokenFrom(from, tokenId);
    _addTokenTo(to, tokenId);

    emit Transfer(from, to, tokenId);
  }

  /**
   * Internal function determines whether the specified token exists.
   * @param tokenId uint256 ID of the token to query the existence of.
   * @return A bool representing whether the token exists.
   */
  function _exists(uint256 tokenId) internal view returns (bool) {
    return _tokenOwner[tokenId] != address(0);
  }

  /**
   * Internal function to mint a new token.
   * Reverts if the given token ID already exists.
   * @param to The address that will own the minted token.
   * @param tokenId uint256 ID of the token to be minted.
   */
  function _mint(address to, uint256 tokenId) internal {
    require(to != address(0));
    _addTokenTo(to, tokenId);
    emit Transfer(address(0), to, tokenId);
  }

  /**
   * Internal function to burn a specific token.
   * Reverts if the token does not exist.
   * @param tokenId uint256 ID of the token to be burned.
   */
  function _burn(address owner, uint256 tokenId) internal {
    _clearApproval(owner, tokenId);
    _removeTokenFrom(owner, tokenId);
    emit Transfer(owner, address(0), tokenId);
  }

  /**
   * Internal function to remove a token ID from the list of a given address.
   * @param from The address of the token's previous owner.
   * @param tokenId uint256 ID of the token.
   */
  function _removeTokenFrom(address from, uint256 tokenId) internal {
    require(ownerOf(tokenId) == from);
    _ownedTokensCount[from] = _ownedTokensCount[from].sub(1);
    _tokenOwner[tokenId] = address(0);
  }

  /**
    * @dev Internal function to add a token ID to the list of a given address
    * Note that this function is left internal to make ERC721Enumerable possible, but is not
    * intended to be called by custom derived contracts: in particular, it emits no Transfer event.
    * @param to address representing the new owner of the given token ID
    * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
    */
  function _addTokenTo(address to, uint256 tokenId) internal {
    require(_tokenOwner[tokenId] == address(0));
    _tokenOwner[tokenId] = to;
    _ownedTokensCount[to] = _ownedTokensCount[to].add(1);
  }

  /**
   * Private function to clear approval of a given token.
   * @param owner The address of the token's owner.
   * @param tokenId uint256 ID of the token.
   */
  function _clearApproval(address owner, uint256 tokenId) private {
    require(ownerOf(tokenId) == owner);
    if (_tokenApprovals[tokenId] != address(0)) {
      _tokenApprovals[tokenId] = address(0);
    }
  }

}
