const each = require('..')
const assert = require('assert')

each([1, 2, 3])
.parallel(true)
.call(function(val, callback){
  setImmediate( () => {
    callback( val % 2 && new Error("Invalid") )
  })
})
.next(function(err, count) {
  const succeed = count - err.errors.length
  assert.equal(succeed, 1)
})
