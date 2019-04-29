const utils = require('./Utils')
const BigNumber = require('bignumber.js')

const Gold = artifacts.require('Gold')
const checkEvent = utils.checkEvent
const zero40 = utils.zero40

const amount = 100

contract('ERC20PositiveTests', async function (accounts) {

  beforeEach('Make fresh contract', async function () {
    // We let accounts[5] represent the Game.
    gold = await Gold.new({from: accounts[5]})
  })

  it('should return correct totalSupply', async function () {
    assert.equal((await gold.totalSupply()).toNumber(), 0)
  })

  it('should return correct balanceOf', async function () {
    assert.equal((await gold.balanceOf(accounts[0])).toNumber(), 0)
  })

  it('should return correct allowance', async function () {
    assert.equal((await gold.allowance(accounts[0], accounts[1])).toNumber(), 0)
  })

  it('should mint, increasing totalSupply and recipient balance', async function () {
    let event = await gold.mint(accounts[0], amount, {from: accounts[5]})
    checkEvent('Transfer', event, [zero40, accounts[0], new BigNumber(amount)])

    assert.equal((await gold.balanceOf(accounts[0])).toNumber(), amount)
    assert.equal((await gold.totalSupply()).toNumber(), amount)
  })

  it('should burn, decreasing totalSupply and recipient balance', async function () {
    await gold.mint(accounts[0], amount, {from: accounts[5]})
    let event = await gold.burn(accounts[0], amount, {from: accounts[5]})
    checkEvent('Transfer', event, [accounts[0], zero40, new BigNumber(amount)])

    assert.equal((await gold.balanceOf(accounts[0])).toNumber(), 0)
    assert.equal((await gold.totalSupply()).toNumber(), 0)
  })

  it('should transfer, decreasing sender balance and increasing recipient balance', async function () {
    await gold.mint(accounts[0], amount, {from: accounts[5]})
    let event = await gold.transfer(accounts[1], amount, {from: accounts[0]})
    checkEvent('Transfer', event, [accounts[0], accounts[1], new BigNumber(amount)])

    assert.equal((await gold.balanceOf(accounts[0])).toNumber(), 0)
    assert.equal((await gold.balanceOf(accounts[1])).toNumber(), amount)
    assert.equal((await gold.totalSupply()).toNumber(), amount)
  })

  it('should transfer to self without changing balance', async function () {
    await gold.mint(accounts[0], amount, {from: accounts[5]})
    let event = await gold.transfer(accounts[0], amount, {from: accounts[0]})
    checkEvent('Transfer', event, [accounts[0], accounts[0], new BigNumber(amount)])

    assert.equal((await gold.balanceOf(accounts[0])).toNumber(), amount)
    assert.equal((await gold.totalSupply()).toNumber(), amount)
  })

  it('should approve, increasing spender allowance', async function () {
    await gold.mint(accounts[0], amount, {from: accounts[5]})
    let event = await gold.approve(accounts[1], amount, {from: accounts[0]})
    checkEvent('Approval', event, [accounts[0], accounts[1], new BigNumber(amount)])

    assert.equal((await gold.balanceOf(accounts[0])).toNumber(), amount)
    assert.equal((await gold.allowance(accounts[0], accounts[1])).toNumber(), amount)
    assert.equal((await gold.totalSupply()).toNumber(), amount)
  })

  it('should approve self, increasing self allowance', async function () {
    await gold.mint(accounts[0], amount, {from: accounts[5]})
    let event = await gold.approve(accounts[0], amount, {from: accounts[0]})
    checkEvent('Approval', event, [accounts[0], accounts[0], new BigNumber(amount)])

    assert.equal((await gold.balanceOf(accounts[0])).toNumber(), amount)
    assert.equal((await gold.allowance(accounts[0], accounts[0])).toNumber(), amount)
    assert.equal((await gold.totalSupply()).toNumber(), amount)
  })

  it('should transferFrom, reducing spender allowance and transfering from sender to recipient', async function () {
    await gold.mint(accounts[0], amount, {from: accounts[5]})
    await gold.approve(accounts[1], amount, {from: accounts[0]})
    let event = await gold.transferFrom(accounts[0], accounts[2], amount, {from: accounts[1]})
    checkEvent('Transfer', event, [accounts[0], accounts[2], new BigNumber(amount)])

    assert.equal((await gold.balanceOf(accounts[0])).toNumber(), 0)
    assert.equal((await gold.balanceOf(accounts[2])).toNumber(), amount)
    assert.equal((await gold.allowance(accounts[0], accounts[1])).toNumber(), 0)
    assert.equal((await gold.totalSupply()).toNumber(), amount)
  })

  it('should transferFrom to self without changing balance', async function () {
    await gold.mint(accounts[0], amount, {from: accounts[5]})
    await gold.approve(accounts[0], amount, {from: accounts[0]})
    let event = await gold.transferFrom(accounts[0], accounts[0], amount, {from: accounts[0]})
    checkEvent('Transfer', event, [accounts[0], accounts[0], new BigNumber(amount)])

    assert.equal((await gold.balanceOf(accounts[0])).toNumber(), amount)
    assert.equal((await gold.allowance(accounts[0], accounts[0])).toNumber(), 0)
    assert.equal((await gold.totalSupply()).toNumber(), amount)
  })

})
