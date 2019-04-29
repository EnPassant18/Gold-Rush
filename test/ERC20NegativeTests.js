const utils = require('./Utils')

const Gold = artifacts.require('Gold')
const expectRevert = utils.expectRevert

const amount = 100

contract('ERC20NegativeTests', async function (accounts) {

  beforeEach('Make fresh contract', async function () {
    // We let accounts[5] represent the Game.
    gold = await Gold.new({from: accounts[5]})
  })

  it('should fail to approve to address(0)', async function () {
    await gold.mint(accounts[0], amount, {from: accounts[5]})
    await expectRevert(gold.approve('0x0', amount, {from: accounts[0]}))

    assert.equal((await gold.balanceOf(accounts[0])).toNumber(), amount)
    assert.equal((await gold.totalSupply()).toNumber(), amount)
  })

  it('should fail to transferFrom more than spender allowance', async function () {
    await gold.mint(accounts[0], amount, {from: accounts[5]})
    await gold.approve(accounts[1], amount-1, {from: accounts[0]})
    await expectRevert(
      gold.transferFrom(accounts[0], accounts[2], amount, {from: accounts[1]})
    )

    assert.equal((await gold.balanceOf(accounts[0])).toNumber(), amount)
    assert.equal((await gold.allowance(accounts[0], accounts[1])).toNumber(), amount-1)
    assert.equal((await gold.totalSupply()).toNumber(), amount)
  })

  it('should fail to transferFrom more than owner balance', async function () {
    await gold.mint(accounts[0], amount, {from: accounts[5]})
    await gold.approve(accounts[1], amount+1, {from: accounts[0]})
    await expectRevert(
      gold.transferFrom(accounts[0], accounts[2], amount+1, {from: accounts[1]})
    )

    assert.equal((await gold.balanceOf(accounts[0])).toNumber(), amount)
    assert.equal((await gold.allowance(accounts[0], accounts[1])).toNumber(), amount+1)
    assert.equal((await gold.totalSupply()).toNumber(), amount)
  })

  it('should fail to transferFrom to address(0)', async function () {
    await gold.mint(accounts[0], amount, {from: accounts[5]})
    await gold.approve(accounts[1], amount, {from: accounts[0]})
    await expectRevert(
      gold.transferFrom(accounts[0], '0x0', amount, {from: accounts[1]})
    )

    assert.equal((await gold.balanceOf(accounts[0])).toNumber(), amount)
    assert.equal((await gold.allowance(accounts[0], accounts[1])).toNumber(), amount)
    assert.equal((await gold.totalSupply()).toNumber(), amount)
  })

  it('should fail to transfer more than balance', async function () {
    await expectRevert(gold.transfer(accounts[1], amount), {from: accounts[0]})
  })

  it('should fail to transfer to address(0)', async function () {
    await gold.mint(accounts[0], amount, {from: accounts[5]})
    await expectRevert(gold.transfer('0x0', amount, {from: accounts[0]}))

    assert.equal((await gold.balanceOf(accounts[0])).toNumber(), amount)
    assert.equal((await gold.totalSupply()).toNumber(), amount)
  })

  it('should fail to mint to address(0)', async function () {
    await expectRevert(gold.mint('0x0', amount, {from: accounts[5]}))
  })

  it('should fail to burn from address(0)', async function () {
    await expectRevert(gold.burn('0x0', 0, {from: accounts[5]}))
  })

  it('should fail to burn more than balance', async function () {
    await expectRevert(gold.burn(accounts[0], amount, {from: accounts[5]}))
  })

})
