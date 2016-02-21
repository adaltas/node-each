
should = require 'should'
each = require '../src/each'

describe 'Callback', ->
  
  describe 'array', ->
        
    it 'should provide only next argument', (next) ->
      each( [ 'a', 'b', 'c' ] )
      .call (next) ->
        arguments.length.should.eql 1
        next()
      .then next
      
    it 'should provide element and next argument', (next) ->
      each( [ 'a', 'b', 'c' ] )
      .call (element, next) ->
        ['a', 'b', 'c'].should.containEql element
        next()
      .then next
      
    it 'should provide element, index and next argument', (next) ->
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
        
  describe 'object', ->
    
    it 'should provide only next argument', (next) ->
      each( {a: 1, b: 2, c: 3} )
      .call (next) ->
        arguments.length.should.eql 1
        next()
      .then next
      
    it 'should provide value and next argument', (next) ->
      each( {a: 1, b: 2, c: 3} )
      .call (value, next) ->
        value.should.be.a.Number()
        next()
      .then next
      
    it 'should provide key, value and next argument', (next) ->
      each( {a: 1, b: 2, c: 3} )
      .call (key, value, next) ->
        ['a', 'b', 'c'].should.containEql key
        value.should.be.a.Number()
        next()
      .then next
      
    it 'should provide key, value, index and next argument', (next) ->
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
