const utils = require('./Utils')

const Gold = artifacts.require('Gold')
const expectRevert = utils.expectRevert

const amount = 100

contract('GoldNegativeTests', async function (accounts) {

  beforeEach('Make fresh contract', async function () {
    // We let accounts[5] represent the Game.
    gold = await Gold.new({from: accounts[5]})
  })

  it('should fail to mint if not Game', async function () {
    await expectRevert(gold.mint(accounts[0], amount, {from: accounts[2]}))
    let balance = await gold.balanceOf.call(accounts[0])
    assert.equal(balance, 0)
  })

  it('should fail to burn if not Game', async function () {
    await gold.mint(accounts[0], amount, {from: accounts[5]})
    await expectRevert(gold.burn(accounts[0], amount, {from: accounts[2]}))
    let balance = await gold.balanceOf.call(accounts[0])
    assert.equal(balance, amount)
  })

})
