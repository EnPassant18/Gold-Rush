const utils = require('./Utils')
const fastForward = utils.fastForward;

const Lode = artifacts.require('Lode')
const Player = artifacts.require('Player')
const Game = artifacts.require('Game')
const Gold = artifacts.require('Gold')

contract('LodePositiveTests', async function(accounts) {

  beforeEach('Make fresh contracts', async function() {
    game = await Game.new(2, 2, accounts[0], accounts[1])
    player = Player.at((await game.register({from: accounts[2]})).logs[0].args.player)
    await player.buyGold({from: accounts[2], value: 4})
    await player.buyNewLode({from: accounts[2]})
    lodeAddress = await player.lodes(0)
    lode = Lode.at(lodeAddress)
  })

  it('should have correct initial state', async function() {
    assert.equal(await lode.owner(), player.address);
    assert.equal(await lode.game(), game.address);
    assert.equal(await lode.deposit(), 4);
    assert.equal(await lode.equipment(), 0);
  })

  it('should allow changing the deposit', async function() {
    await player.lodeSetDeposit(0, 0, {from: accounts[2]})
    assert.equal(await lode.deposit(), 0);
    assert.equal(await lode.lastCollect(), web3.eth.getBlock('latest').number);
  })

  it('should allow stop mining', async function() {
    await player.lodeSetDeposit(0, 0, {from: accounts[2]})
    await player.lodeStopMining(0, {from: accounts[2]})
    assert.equal(await lode.deposit(), 4);
  })

  it('should award mined resources on collect', async function() {
    await player.lodeSetDeposit(0, 0, {from: accounts[2]})
    fastForward(6505)
    await player.lodeCollect(0, {from: accounts[2]})
    assert.equal(await player.goldBalance(), 1)
    assert.equal(await Gold.at(await game.GoldContract()).balanceOf(player.address), 1)
    assert.equal(await lode.yieldsPerDeposit(0), 249)
  })

  it('should allow crafting and changing equipment', async function() {
    await player.lodeSetDeposit(0, 0, {from: accounts[2]})
    while ((await player.resources(0)).toNumber() === 0) {
      fastForward(6505)
      await player.lodeCollect(0, {from: accounts[2]})
    }
    await player.craft(1, {from: accounts[2]})
    assert.equal(await player.resources(0), 0)
    assert.equal(await player.equipmentOwned(1), 1)
    await player.lodeSetEquipment(0, 1, {from: accounts[2]})
    assert.equal(await player.equipmentInUse(1), 1)
    assert.equal(await lode.equipment(), 1)
  })

})
