
each = require '../src'

describe 'promise', ->
  
  it 'return a promise', (next) ->
    
    each( [ 1, 2, 3 ] )
    .call (element, index, callback) ->
      if index < 2
      then setImmediate callback
      else next()
    .promise()
    .toString().should.eql '[object Promise]'
