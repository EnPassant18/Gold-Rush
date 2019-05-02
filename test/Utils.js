const assertDiff = require('assert-diff')
assertDiff.options.strict = true

const zero40 = "0x0000000000000000000000000000000000000000"
const zero64 = "0x0000000000000000000000000000000000000000000000000000000000000000"

async function expectRevert(contractPromise) {
  try {
    await contractPromise;
  } catch (error) {
    assert(
      error.message.search('revert') >= 0,
      'Expected error of type revert, got \'' + error + '\' instead',
    );
    return;
  }
  assert.fail('Expected error of type revert, but no error was received');
}

function checkEvent(type, event, params) {
  let eventFound = false
  event.logs.forEach((o) => {
    if (o.event === type) {
      eventFound = true
      assertDiff.deepEqual(Object.values(o.args), params)
    }
  })
  if (!eventFound) {
    throw new Error('The specified event was not emmitted: ' + type)
  }
}

module.exports = {
  expectRevert: expectRevert,
  checkEvent: checkEvent,
  zero40: zero40,
  zero64: zero64
}
