
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
      
  it 'catch error before promise', (next) ->
    err = null
    each( [ 1, 2, 3 ] )
    .call (element, index, callback) ->
      throw Error 'CatchMe'
    .error (e) ->
      err = e
    .promise()
    .then ->
      err.message.should.eql 'CatchMe'
      next()
    , ->
      next Error 'Bad'
        
  it 'catch error before promise', (next) ->
    called = false
    each( [ 1, 2, 3 ] )
    .call (element, index, callback) ->
      callback()
    .then ->
      called = true
    .promise()
    .then ->
      called.should.be.true()
      next()
    , ->
      next Error 'Bad'
      
