
should = require 'should'
each = if process.env.EACH_COV then require '../lib-cov/each' else require '../lib/each'

describe 'Error', ->
  it 'Concurrent # error and both callbacks', (next) ->
    current = 0
    error_called = false
    error_assert = (err, errs) ->
      current.should.eql 9
      err.message.should.eql 'Multiple errors (2)'
      errs.length.should.eql 2
      errs[0].message.should.eql 'Testing error in 6'
      errs[1].message.should.eql 'Testing error in 7'
    each( [ {id: 1}, {id: 2}, {id: 3}, {id: 4}, {id: 5}, {id: 6}, {id: 7}, {id: 8}, {id: 9}, {id: 10}, {id: 11} ] )
    .parallel( 4 )
    .on 'item', (element, index, next) ->
      index.should.eql current
      current++
      setTimeout ->
        if element.id is 6 or element.id is 7
          next new Error "Testing error in #{element.id}"
        else 
          next()
      , 100
    .on 'error', (err, errs) ->
      error_assert.call null, err, errs
      error_called = true
    .on 'end', (err, errs) ->
      assert.ok false
    .on 'both', (err, errs) ->
      error_called.should.be.ok 
      error_assert.call null, err, errs
      next()
  it 'Concurrent # throw error', (next) ->
    current = 0
    error_called = false
    error_assert = (err, errs) ->
      current.should.eql 6
      err.message.should.eql 'Testing error in 6'
      errs.length.should.eql 1
      errs[0].message.should.eql 'Testing error in 6'
    each( [ {id: 1}, {id: 2}, {id: 3}, {id: 4}, {id: 5}, {id: 6}, {id: 7}, {id: 8}, {id: 9}, {id: 10}, {id: 11} ] )
    .parallel( 4 )
    .on 'item', (element, index, next) ->
      index.should.eql current
      current++
      if element.id is 6 or element.id is 7
        throw new Error "Testing error in #{element.id}"
      else 
        next()
    .on 'error', (err, errs) ->
      error_assert.call null, err, errs
      error_called = true
    .on 'end', (err, errs) ->
      assert.ok false
    .on 'both', (err, errs) ->
      error_called.should.be.ok 
      error_assert.call null, err, errs
      next()
  it 'Parallel # multiple errors # error callback', (next) ->
    # when multiple errors are thrown, a new error object is created
    # with a message indicating the number of errors. The original 
    # errors are available as an array in the second argument of the
    # `error` event.
    current = 0
    each( [{id: 1}, {id: 2}, {id: 3}, {id: 4}] )
    .parallel( true )
    .on 'item', (element, index, next) ->
      index.should.eql current
      current++
      setTimeout ->
        if element.id is 1 or element.id is 3
          next( new Error "Testing error in #{element.id}" )
        else
          next()
      , 100
    .on 'error', (err, errs) ->
      err.message.should.eql 'Multiple errors (2)'
      errs.length.should.eql 2
      errs[0].message.should.eql 'Testing error in 1'
      errs[1].message.should.eql 'Testing error in 3'
      return next()
    .on 'end', (err, errs) ->
      false.should.be.ok 
  it 'Parallel # single error # error callback', (next) ->
    # when on one error is thrown, the error is passed to
    # the `error` event as is as well as a single element array 
    # of the second argument.
    current = 0
    each( [{id: 1}, {id: 2}, {id: 3}, {id: 4}] )
    .parallel( true )
    .on 'item', (element, index, next) ->
      index.should.eql current
      current++
      setTimeout ->
        if element.id is 3
          next( new Error "Testing error in #{element.id}" )
        else
          next()
      , 100
    .on 'error', (err, errs) ->
      err.message.should.eql 'Testing error in 3'
      errs.length.should.eql 1
      errs[0].message.should.eql 'Testing error in 3'
      return next()
    .on 'end', (err, errs) ->
      false.should.be.ok 
  it 'Parallel # async # both callback', (next) ->
    current = 0
    each( [{id: 1}, {id: 2}, {id: 3}, {id: 4}] )
    .parallel( true )
    .on 'item', (element, index, next) ->
      index.should.eql current
      current++
      setTimeout ->
        if element.id is 1 or element.id is 3
          next( new Error "Testing error in #{element.id}" )
        else
          next()
      , 100
    .on 'both', (err, errs) ->
      err.message.should.eql 'Multiple errors (2)'
      errs.length.should.eql 2
      errs[0].message.should.eql 'Testing error in 1', 
      errs[1].message.should.eql 'Testing error in 3'
      return next()
    .on 'end', (err, errs) ->
      false.should.be.ok 
  it 'Parallel # sync # both callback', (next) ->
    current = 0
    each( [{id: 1}, {id: 2}, {id: 3}, {id: 4}] )
    .parallel( true )
    .on 'item', (element, index, next) ->
      index.should.eql current
      current++
      if element.id is 1 or element.id is 3
        next( new Error "Testing error in #{element.id}" )
      else setTimeout next, 100
    .on 'both', (err, errs) ->
      # In this specific case, since the item handler
      # send error sequentially, we are only receiving
      # one error
      err.message.should.eql 'Testing error in 1'
      errs.length.should.eql 1
      next()
  it 'Sequential # sync # error callback', (next) ->
    current = 0
    each( [ {id: 1}, {id: 2}, {id: 3} ] )
    .on 'item', (element, index, next) ->
      index.should.eql current
      current++
      if element.id is 2
        next( new Error 'Testing error' )
      else next()
    .on 'error', (err) ->
      err.message.should.eql 'Testing error'
      next()
    .on 'end', (err, errs) ->
      false.should.be.ok 
  it 'Sequential # async # error callback', (next) ->
    current = 0
    each( [ {id: 1}, {id: 2}, {id: 3} ] )
    .on 'item', (element, index, next) ->
      index.should.eql current
      current++
      if element.id is 2
        setTimeout -> 
          next( new Error 'Testing error' )
        , 100
      else setTimeout next, 100
    .on 'error', (err) ->
      err.message.should.eql 'Testing error'
      next()
    .on 'end', (err, errs) ->
      false.should.be.ok 
  