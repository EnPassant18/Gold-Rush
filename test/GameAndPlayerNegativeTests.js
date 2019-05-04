const utils = require('./Utils')

const Game = artifacts.require('Game')
const Player = artifacts.require('Player')
const Lode = artifacts.require('Lode')
const Gold = artifacts.require('Gold')
const expectRevert = utils.expectRevert

const amount = 100

contract('PlayerNegativeTests', async function (accounts) {

  beforeEach('Make fresh contract', async function () {
    player = await Player.new(accounts[1], {from: accounts[0]})
  })

  it('should only be controlled by the owner', async function () {
    await expectRevert(player.setOwner(accounts[2], {from: accounts[0]}))
    await expectRevert(player.lodeSetEquipment(0, 0, {from: accounts[0]}))
    await expectRevert(player.lodeSetDeposit(0, 0, {from: accounts[0]}))
    await expectRevert(player.lodeSetDepositAndEquipment(0, 0, 0, {from: accounts[0]}))
    await expectRevert(player.lodeStopMining(0, {from: accounts[0]}))
    await expectRevert(player.lodeCollect(0, {from: accounts[0]}))
    await expectRevert(player.sellLode(0, 1, {from: accounts[0]}))
    await expectRevert(player.buyLode(0, {from: accounts[0]}))
    await expectRevert(player.craft(0, {from: accounts[0]}))
    await expectRevert(player.buyGold({from: accounts[0], value: 10}))
  })

})

contract('GameNegativeTests', async function (accounts) {

  beforeEach('Make fresh contract', async function () {
    game = await Game.new(1, 1, accounts[0], accounts[1])
  })

  it('should fail to initialize given invalid arguments', async function () {
    await expectRevert(Game.new(0, 1, accounts[0], accounts[1]))
    await expectRevert(Game.new(1, 0, accounts[0], accounts[1]))
    await expectRevert(Game.new(1, 1, 0, accounts[1]))
    await expectRevert(Game.new(1, 1, accounts[0], 0))
  })

  it('should fail to set moderator if caller is not moderator', async function () {
    await expectRevert(game.setModerator(accounts[2], {from: accounts[5]}))
  })

  it('should fail to set moderator to zero', async function () {
    await expectRevert(game.setModerator(0, {from: accounts[0]}))
  })

  it('should fail to set gold price if caller is not moderator', async function () {
    await expectRevert(game.setNewGoldPrice(5, {from: accounts[5]}))
  })

  it('should fail to set gold price to zero', async function () {
    await expectRevert(game.setNewGoldPrice(0, {from: accounts[0]}))
  })

  it('should fail to set new lode price if caller is not moderator', async function () {
    await expectRevert(game.setNewLodePrice(5, {from: accounts[5]}))
  })

  it('should fail to set new lode price to zero', async function () {
    await expectRevert(game.setNewLodePrice(0, {from: accounts[0]}))
  })

})

contract('GameAndPlayerNegativeTests', async function (accounts) {

  beforeEach('Make fresh contracts', async function () {
    game = await Game.new(2, 2, accounts[0], accounts[1])
    player = Player.at((await game.register({from: accounts[2]})).logs[0].args.player)
    player2 = Player.at((await game.register({from: accounts[3]})).logs[0].args.player)
    await player.buyGold({from: accounts[2], value: 4})
    await player.buyNewLode({from: accounts[2]})
    lodeAddress = await player.lodes(0)
    lode = Lode.at(lodeAddress)
  })

  it('should not allow unregistered players to buy new gold/lodes', async function () {
    await expectRevert(game.buyNewLode({from: accounts[5]}))
    await expectRevert(game.buyGold({from: accounts[5], value: 100}))
  })

  it('should not allow unregistered players to buy lodes', async function () {
    await player.sellLode(0, 10, {from: accounts[2]})
    await expectRevert(game.buyLode(lodeAddress, {from: accounts[4]}))
  })

  it('should buy no gold if funds are insufficient', async function () {
    await player.buyGold({from: accounts[2], value: 1})
    assert.equal(await Gold.at(await game.GoldContract()).balanceOf(player.address), 0)
  })

  it('should fail to buy new lode if funds are insufficient', async function () {
    await player.buyGold({from: accounts[2], value: 2})
    await expectRevert(player.buyNewLode({from: accounts[2]}))
  })

  it('should fail to buy lode if funds are insufficient', async function () {
    await player2.buyGold({from: accounts[3], value: 2})
    await player.sellLode(0, 10, {from: accounts[2]})
    await expectRevert(player2.buyLode(lodeAddress, {from: accounts[3]}))
  })

  it('should fail to lodeMint if not registered lode', async function () {
    await expectRevert(game.lodeMint(accounts[3], 10000, {from: accounts[3]}))
  })

})