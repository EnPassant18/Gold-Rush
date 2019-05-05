const utils = require('./Utils')
const expectRevert = utils.expectRevert;

const Lode = artifacts.require('Lode')
const Player = artifacts.require('Player')
const Game = artifacts.require('Game')

contract('LodeNegativeTests', async function(accounts) {

  beforeEach('Make fresh contracts', async function() {
    game = await Game.new(2, 2, accounts[0], accounts[1])
    player = Player.at((await game.register({from: accounts[2]})).logs[0].args.player)
    await player.buyGold({from: accounts[2], value: 4})
    await player.buyNewLode({from: accounts[2]})
    lodeAddress = await player.lodes(0)
    lode = Lode.at(lodeAddress)
  })

  it('should not allow invalid owner change', async function() {
    await expectRevert(lode.setOwner(accounts[5], {from: accounts[5]}))
  })

  it('should not allow changing to invalid deposit', async function() {
    await expectRevert(player.lodeSetDeposit(0, 4, {from: accounts[2]}))
    await expectRevert(player.lodeSetDeposit(0, 3, {from: accounts[2]}))
  })

  it('should not allow changing to invalid equipment', async function() {
    await expectRevert(player.lodeSetEquipment(0, 14, {from: accounts[2]}))
    await expectRevert(player.lodeSetEquipment(0, 13, {from: accounts[2]}))
  })

  it('should not allow invalid crafting of equipment', async function() {
    await expectRevert(player.craft(10, {from: accounts[2]}))
  })

})
