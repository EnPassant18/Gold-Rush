const utils = require('./Utils')
const BigNumber = require('bignumber.js')

const Game = artifacts.require('Game')
const Gold = artifacts.require('Gold')
const Player = artifacts.require('Player')
const Lode = artifacts.require('Lode')
const checkEvent = utils.checkEvent
const zero40 = utils.zero40

const amount = 100

contract('PlayerPositiveTests', async function (accounts) {

  beforeEach('Make fresh contract', async function () {
    player = await Player.new(accounts[1], {from: accounts[0]})
  })

  it('should have the correct initial state', async function () {
    assert.equal(await player.owner(), accounts[1])
    assert.equal(await player.game(), accounts[0])
    assert.equal(await player.goldBalance(), 0)
  })

  it('should change owners', async function () {
    await player.setOwner(accounts[2], {from: accounts[1]})
    assert.equal(await player.owner(), accounts[2])
  })

})

contract('GamePositiveTests', async function (accounts) {

  beforeEach('Make fresh contract', async function () {
    game = await Game.new(1, 1, accounts[0], accounts[1])
  })

  it('should have the correct initial state', async function () {
    assert.equal(await game.moderator(), accounts[0])
    assert.equal(await game.wallet(), accounts[1])
    assert.equal(await game.weiCollected(), 0)
    assert.equal(await game.goldPrice(), 1)
    assert.equal(await game.newLodePrice(), 1)
  })

  it('should set moderator', async function () {
    await game.setModerator(accounts[2], {from: accounts[0]})
    assert.equal(await game.moderator(), accounts[2])
  })

  it('should set gold price', async function () {
    await game.setNewGoldPrice(2, {from: accounts[0]})
    assert.equal(await game.goldPrice(), 2)
  })

  it('should set new lode price', async function () {
    await game.setNewLodePrice(2, {from: accounts[0]})
    assert.equal(await game.newLodePrice(), 2)
  })

})

contract('GameAndPlayerPositiveTests', async function (accounts) {

  beforeEach('Make fresh contracts', async function () {
    game = await Game.new(2, 2, accounts[0], accounts[1])
    player = Player.at((await game.register({from: accounts[2]})).logs[0].args.player)
  })

  it('should correctly instantiate a registered player', async function () {
    assert.equal(await player.owner(), accounts[2])
    assert.equal(await player.game(), game.address)
  })

  it('should register the new player', async function () {
    assert.equal(await game.registration(player.address), true)
  })

  it('should sell gold to the player', async function () {
    await player.buyGold({from: accounts[2], value: 7})
    assert.equal((await game.weiCollected()).toNumber(), 6)
    assert.equal(web3.eth.getBalance(player.address).toNumber(), 1)
    assert.equal(await Gold.at(await game.GoldContract()).balanceOf(player.address), 3)
    assert.equal(await player.goldBalance(), 3)
  })

  it('should sell new lodes to the player', async function () {
    await player.buyGold({from: accounts[2], value: 7})
    await player.buyNewLode({from: accounts[2]})
    assert.equal(await Gold.at(await game.GoldContract()).balanceOf(player.address), 1)
    assert.equal(await player.goldBalance(), 1)
    lodeAddress = await player.lodes(0)
    assert.notEqual(lodeAddress, 0)
    assert.equal(await player.lodesOwned(), 1)
    assert.equal(await game.lodeRegistration(lodeAddress), true)
    assert.equal(await Lode.at(lodeAddress).owner(), player.address)
  })

  it('should allow players to buy/sell lodes', async function () {
    player2 = Player.at((await game.register({from: accounts[3]})).logs[0].args.player)
    await player.buyGold({from: accounts[2], value: 4})
    await player2.buyGold({from: accounts[3], value: 30})
    await player.buyNewLode({from: accounts[2]})
    lodeAddress = await player.lodes(0)
    await player.sellLode(0, 10, {from: accounts[2]})

    assert.equal((await game.lodesForSale(lodeAddress))[0].toNumber(), 10)
    assert.equal((await game.lodesForSale(lodeAddress))[1], player.address)

    await player2.buyLode(lodeAddress, {from: accounts[3]})

    assert.equal(await Gold.at(await game.GoldContract()).balanceOf(player.address), 10)
    assert.equal(await Gold.at(await game.GoldContract()).balanceOf(player2.address), 5)
    assert.equal((await player.goldBalance()).toNumber(), 10)
    assert.equal((await player2.goldBalance()).toNumber(), 5)
    assert.equal(await player2.lodes(0), lodeAddress)
    assert.equal((await player.lodesOwned()).toNumber(), 0)
    assert.equal((await player2.lodesOwned()).toNumber(), 1)
    assert.equal(await game.lodeRegistration(lodeAddress), true)
    assert.equal(await Lode.at(lodeAddress).owner(), player2.address)
    assert.equal((await game.lodesForSale(lodeAddress))[1], 0)
  })

})