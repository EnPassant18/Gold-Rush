const utils = require('./Utils')
const Lode = artifacts.require('Lode')

const amount = 100

contract('LodePositiveTests', async function(accounts) {

  beforeEach('Make fresh contract', async function() {
    //let account[0] represent the owner. let account[5] represent the Game
    lode = await Lode.new(accounts[0], {from: accounts[5]})
  })

  it('no resources should be minded', async function() {
    let collection = await lode.collect.call()
    assert.equal(collection[0].toNumber(), 0)

    collection[1].forEach(function(item) {
      assert.equal(item.toNumber(), 0)
    });
  })

})
