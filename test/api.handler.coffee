
should = require 'should'
each = require '../src'

describe 'handler', ->
  
  describe 'arguments from array', ->
        
    it 'get next argument', (next) ->
      each( [ 'a', 'b', 'c' ] )
      .call (next) ->
        arguments.length.should.eql 1
        next()
      .then next
      
    it 'get element and next argument', (next) ->
      each( [ 'a', 'b', 'c' ] )
      .call (element, next) ->
        ['a', 'b', 'c'].should.containEql element
        next()
      .then next
      
    it 'get element, index and next argument', (next) ->
      each( [ 'a', 'b', 'c' ] )
      .call (element, index, next) ->
        ['a', 'b', 'c'].should.containEql element
        index.should.be.a.Number()
        next()
      .then next
      
    it 'throw error with no argument', (next) ->
      each( ['a', 'b', 'c'] )
      .call () ->
        false.should.be.true()
      .then (err) ->
        err.message.should.eql 'Invalid arguments in item callback'
        next()
        
  describe 'arguments from object', ->
    
    it 'get next argument', (next) ->
      each( {a: 1, b: 2, c: 3} )
      .call (next) ->
        arguments.length.should.eql 1
        next()
      .then next
      
    it 'get value and next argument', (next) ->
      each( {a: 1, b: 2, c: 3} )
      .call (value, next) ->
        value.should.be.a.Number()
        next()
      .then next
      
    it 'get key, value and next argument', (next) ->
      each( {a: 1, b: 2, c: 3} )
      .call (key, value, next) ->
        ['a', 'b', 'c'].should.containEql key
        value.should.be.a.Number()
        next()
      .then next
      
    it 'get key, value, index and next argument', (next) ->
      each( {a: 1, b: 2, c: 3} )
      .call (key, value, counter, next) ->
        ['a', 'b', 'c'].should.containEql key
        value.should.be.a.Number()
        counter.should.be.a.Number()
        next()
      .then next
      
    it 'throw error with no argument', (next) ->
      each( {a: 1, b: 2, c: 3} )
      .call () ->
        false.should.be.true()
      .then (err) ->
        err.message.should.eql 'Invalid arguments in item callback'
        next()
