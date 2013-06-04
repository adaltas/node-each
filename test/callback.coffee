
should = require 'should'
each = if process.env.EACH_COV then require '../lib-cov/each' else require '../lib/each'

describe 'Callback', ->
  describe 'array', ->
    it 'should provide only next argument', (next) ->
      each( [ 'a', 'b', 'c' ] )
      .on 'item', (next) ->
        arguments.length.should.eql 1
        next()
      .on 'end', -> next()
    it 'should provide element and next argument', (next) ->
      each( [ 'a', 'b', 'c' ] )
      .on 'item', (element, next) ->
        ['a', 'b', 'c'].should.include element
        next()
      .on 'end', -> next()
    it 'should provide element, index and next argument', (next) ->
      each( [ 'a', 'b', 'c' ] )
      .on 'item', (element, index, next) ->
        ['a', 'b', 'c'].should.include element
        index.should.be.a 'number'
        next()
      .on 'end', -> next()
    it 'throw error with no argument', (next) ->
      each( ['a', 'b', 'c'] )
      .on 'item', () ->
        false.should.be.true
      .on 'error', (err) ->
        err.message.should.eql 'Invalid arguments in item callback'
        next()
  describe 'object', ->
    it 'should provide only next argument', (next) ->
      each( {a: 1, b: 2, c: 3} )
      .on 'item', (next) ->
        arguments.length.should.eql 1
        next()
      .on 'end', -> next()
    it 'should provide value and next argument', (next) ->
      each( {a: 1, b: 2, c: 3} )
      .on 'item', (value, next) ->
        value.should.be.a 'number'
        next()
      .on 'end', -> next()
    it 'should provide key, value and next argument', (next) ->
      each( {a: 1, b: 2, c: 3} )
      .on 'item', (key, value, next) ->
        ['a', 'b', 'c'].should.include key
        value.should.be.a 'number'
        next()
      .on 'end', -> next()
    it 'should provide key, value, index and next argument', (next) ->
      each( {a: 1, b: 2, c: 3} )
      .on 'item', (key, value, counter, next) ->
        ['a', 'b', 'c'].should.include key
        value.should.be.a 'number'
        counter.should.be.a 'number'
        next()
      .on 'end', -> next()
    it 'throw error with no argument', (next) ->
      each( {a: 1, b: 2, c: 3} )
      .on 'item', () ->
        false.should.be.true
      .on 'error', (err) ->
        err.message.should.eql 'Invalid arguments in item callback'
        next()
  describe 'next', ->
    # it.only 'called multiple times in sequential mode', (next) ->
    #   each( [ 'a', 'b', 'c' ] )
    #   .parallel(1)
    #   .on 'item', (next) ->
    #     next()
    #     process.nextTick next
    #   .on 'error', (err) ->
    #     console.log 'error'
    #     next()
    #   .on 'end', -> 
    #     console.log 'end'
    it 'in sequential mode, end already thrown', (next) ->
      # Nothing we can do here, end has been thrown and we can not wait for it
      # Catch the uncatchable
      lsts = process.listeners 'uncaughtException'
      process.removeAllListeners 'uncaughtException'
      process.on 'uncaughtException', (err) ->
        # Test
        ended.should.be.ok
        err.message.should.eql 'Multiple call detected'
        # Cleanup and finish
        process.removeAllListeners 'uncaughtException'
        for lst in lsts
          process.on 'uncaughtException', lst
        next()
      # Run the test
      ended = false
      each( [ 'a', 'b', 'c' ] )
      .parallel(1)
      .on 'item', (item, next) ->
        next()
        # We only want to generate one error
        return unless item is 'a'
        process.nextTick next
      .on 'error', (err) ->
        false.should.be.ok
      .on 'end', ->
        ended = true
    it 'in sequential mode, end not thrown', (next) ->
      ended = false
      each( [ 'a', 'b', 'c' ] )
      .parallel(1)
      .on 'item', (item, next) ->
        process.nextTick ->
          next()
          # We only want to generate one error
          return unless item is 'a'
          process.nextTick next
      .on 'error', (err) ->
        ended.should.not.be.ok
        err.message.should.eql 'Multiple call detected'
        next()
      .on 'end', ->
        ended = true
