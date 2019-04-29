const utils = require('./Utils')
const Gold = artifacts.require('Gold')


const amount = 100

contract('GoldPositiveTests', async function (accounts) {

  beforeEach('Make fresh contract', async function () {
    // We let accounts[5] represent the Game.
    gold = await Gold.new({from: accounts[5]})
  })



  it('should be able to mint coins', async function() {
    await gold.mint(accounts[0], amount, {from: accounts[5]})
    await gold.mint(accounts[1], amount, {from: accounts[5]})

    assert.equal((await gold.balanceOf.call(accounts[0])).toNumber(), amount)
    assert.equal((await gold.balanceOf.call(accounts[1])).toNumber(), amount)

  })

  it('should be able to burn coins', async function() {
    await gold.mint(accounts[0], amount, {from: accounts[5]})
    await gold.mint(accounts[1], amount, {from: accounts[5]})

    await gold.burn(accounts[0], amount, {from: accounts[5]})
    await gold.burn(accounts[1], amount, {from: accounts[5]})

    assert.equal((await gold.balanceOf.call(accounts[0])).toNumber(), 0)
    assert.equal((await gold.balanceOf.call(accounts[1])).toNumber(), 0)



  })


})
