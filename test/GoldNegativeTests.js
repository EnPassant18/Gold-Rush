const utils = require('./Utils')

const Lode = utils.Lode
const Gold = utils.Gold
const checkState = utils.checkState
const expectRevert = utils.expectRevert

const amount = 100

contract('GoldNegativeTests', async function (accounts) {

  // This runs before each test.
  beforeEach('Make fresh contract', async function () {
    // We let accounts[5] represent the CryptoBearsContract.
    bearBucks = await BearBucks.new({from: accounts[5]})//{from: BLANK specifies msg.sender}
  })

  it('should have correct initial state', async function () {
    await checkState([bearBucks], [[]], accounts)
  })

  it('should fail to mint if not minter or CryptoBearsContract', async function () {
    await expectRevert(bearBucks.mint(accounts[0], amount, {from: accounts[2]}))
    await checkState([bearBucks], [[]], accounts)
  })

  it('should fail to burn if not minter or CryptoBearsContract', async function () {
    await bearBucks.mint(accounts[0], amount, {from: accounts[5]})
    await expectRevert(bearBucks.burn(accounts[0], amount, {from: accounts[2]}))

    let stateChanges = [
      {'var': 'totalSupply', 'expect': amount},
      {'var': 'balanceOf.a0', 'expect': amount},
    ]
    await checkState([bearBucks], [stateChanges], accounts)
  })

    let stateChanges = [
      {'var': 'totalSupply', 'expect': amount},
      {'var': 'balanceOf.a0', 'expect': amount},
      {'var': 'allowance.a0.cb', 'expect': amount}
    ]
    await checkState([bearBucks], [stateChanges], accounts)
  })

  it('should fail to placeBet greater than balance', async function () {
    await bearBucks.mint(accounts[0], amount, {from: accounts[5]})
    await bearBucks.approve(accounts[5], amount+1, {from: accounts[0]})
    await expectRevert(bearBucks.placeBet(accounts[0], amount+1, {from: accounts[5]}))

    let stateChanges = [
      {'var': 'totalSupply', 'expect': amount},
      {'var': 'balanceOf.a0', 'expect': amount},
      {'var': 'allowance.a0.cb', 'expect': amount+1}
    ]
    await checkState([bearBucks], [stateChanges], accounts)
  })

  it('should fail to placeBet if allowance of CryptoBearsContract is less than betSum', async function () {
    await bearBucks.mint(accounts[0], amount, {from: accounts[5]})
    await bearBucks.approve(accounts[5], amount-1, {from: accounts[0]})
    await expectRevert(bearBucks.placeBet(accounts[0], amount, {from: accounts[5]}))

    let stateChanges = [
      {'var': 'totalSupply', 'expect': amount},
      {'var': 'balanceOf.a0', 'expect': amount},
      {'var': 'allowance.a0.cb', 'expect': amount-1}
    ]
    await checkState([bearBucks], [stateChanges], accounts)
  })



})
