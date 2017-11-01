
each = require '../src'

describe 'error_next', ->
  
  describe 'async', ->
    
    it 'run arguments only contains next', (next) ->
      each( [ 'a', 'b', 'c' ] )
      .call (next) ->
        arguments.length.should.eql 1
        next()
      .next next
      
    it 'run arguments contains element and next', (next) ->
      elements = []
      each( [ 'a', 'b', 'c' ] )
      .call (element, next) ->
        elements.push element
        next()
      .error next
      .next ->
        elements.should.eql [ 'a', 'b', 'c' ]
        next()
    
  describe 'sync', ->
    
    it 'run arguments is empty', (next) ->
      each( [ 'a', 'b', 'c' ] )
      .sync()
      .call ->
        arguments.length.should.eql 0
      .next next
      
    it 'run arguments contains element', (next) ->
      elements = []
      each( [ 'a', 'b', 'c' ] )
      .sync()
      .call (element) ->
        elements.push element
      .error next
      .next ->
        elements.should.eql [ 'a', 'b', 'c' ]
        next()
