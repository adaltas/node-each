
each = require '../src'

describe 'handler', ->
  
  describe 'arguments from array', ->
        
    it 'get next argument', (next) ->
      each( [ 'a', 'b', 'c' ] )
      .call (callback) ->
        arguments.length.should.eql 1
        callback()
      .next next
      
    it 'get element and next argument', (next) ->
      each( [ 'a', 'b', 'c' ] )
      .call (element, callback) ->
        ['a', 'b', 'c'].should.containEql element
        callback()
      .next next
      
    it 'get element, index and next argument', (next) ->
      each( [ 'a', 'b', 'c' ] )
      .call (element, index, callback) ->
        ['a', 'b', 'c'].should.containEql element
        index.should.be.a.Number()
        callback()
      .next next
      
    it 'throw error with no argument', (next) ->
      each( ['a', 'b', 'c'] )
      .call () ->
        false.should.be.true()
      .next (err) ->
        err.message.should.eql 'Invalid arguments in item callback'
        next()
        
  describe 'arguments from object', ->
    
    it 'get next argument', (next) ->
      each( {a: 1, b: 2, c: 3} )
      .call (callback) ->
        arguments.length.should.eql 1
        callback()
      .next next
      
    it 'get value and next argument', (next) ->
      each( {a: 1, b: 2, c: 3} )
      .call (value, callback) ->
        value.should.be.a.Number()
        callback()
      .next next
      
    it 'get key, value and next argument', (next) ->
      each( {a: 1, b: 2, c: 3} )
      .call (key, value, callback) ->
        ['a', 'b', 'c'].should.containEql key
        value.should.be.a.Number()
        callback()
      .next next
      
    it 'get key, value, index and next argument', (next) ->
      each( {a: 1, b: 2, c: 3} )
      .call (key, value, counter, callback) ->
        ['a', 'b', 'c'].should.containEql key
        value.should.be.a.Number()
        counter.should.be.a.Number()
        callback()
      .next next
      
    it 'throw error with no argument', (next) ->
      each( {a: 1, b: 2, c: 3} )
      .call () ->
        false.should.be.true()
      .next (err) ->
        err.message.should.eql 'Invalid arguments in item callback'
        next()
        
  describe 'array', ->
        
    it 'called immediatly', (next) ->
      data = []
      each( [ '1', '2', '3' ] )
      .call [
        (val, callback) -> data.push(val+'a') and callback()
        (val, callback) -> data.push(val+'b') and callback()
      ]
      .error next
      .next ->
        data.should.eql ['1a', '1b', '2a', '2b', '3a', '3b']
        next()
              
    it 'called with delay', (next) ->
      data = []
      each( [ '1', '2', '3' ] )
      .parallel true
      .call [
        (val, callback) -> data.push(val+'a') and callback()
        (val, callback) -> process.nextTick (-> data.push(val+'b') and callback())
      ]
      .error next
      .next ->
        # Not sure how to explain this result, i would have expected
        # ['1a', '2a', '3a', '1b', '2b', '3b']
        data.should.eql ['1a', '2a', '3a', '3b', '2b', '1b']
        next()
        
  describe 'chain', ->
        
    it 'called with delay', (next) ->
      data = []
      each( [ '1', '2', '3' ] )
      .parallel true
      .call (val, callback) -> data.push(val+'a') and callback()
      .call (val, callback) -> data.push(val+'b') and callback()
      .error next
      .next ->
        data.should.eql ['1a', '2a', '3a', '1b', '2b', '3b']
        next()
              
    it 'catch error in first handler', (next) ->
      data = []
      each( [ '1', '2', '3' ] )
      .parallel true
      .call (val, callback) -> throw Error 'Catchme'
      .call (val, callback) -> callback()
      .error (err) ->
        err.message.should.eql 'Catchme'
        next()
      .next ->
        false.should.be.true()
              
    it 'catch error in last handler', (next) ->
      data = []
      each( [ '1', '2', '3' ] )
      .parallel true
      .call (val, callback) -> callback()
      .call (val, callback) -> throw Error 'Catchme'
      .error (err) ->
        err.message.should.eql 'Catchme'
        next()
      .next ->
        false.should.be.true()
              
    it 'get error in first handler', (next) ->
      data = []
      each( [ '1', '2', '3' ] )
      .parallel true
      .call (val, callback) -> setImmediate -> callback Error 'Catchme'
      .call (val, callback) -> callback Error 'Dont call me'
      .error (err) ->
        err.errors.length.should.eql 3
        err.errors[0].message.should.eql 'Catchme'
        next()
      .next ->
        false.should.be.true()
              
    it 'get error in last handler', (next) ->
      data = []
      each( [ '1', '2', '3' ] )
      .parallel true
      .call (val, callback) -> callback()
      .call (val, callback) -> setImmediate -> callback Error 'Catchme'
      .error (err) ->
        err.errors.length.should.eql 3
        err.errors[0].message.should.eql 'Catchme'
        next()
      .next ->
        false.should.be.true()
              
    it 'get multiple call error in first handler', (next) ->
      data = []
      each( [ '1', '2', '3' ] )
      .parallel true
      .call (val, callback) -> setImmediate ->
        callback Error 'Catchme'
        setImmediate -> callback Error 'Catchme'
      .call (val, callback) -> callback Error 'Dont call me'
      .error (err) ->
        err.errors.length.should.eql 3
        err.errors[0].message.should.eql 'Catchme'
        next()
      .next ->
        false.should.be.true()
              
    it 'get multiple call error in last handler', (next) ->
      data = []
      each( [ '1', '2', '3' ] )
      .parallel true
      .call (val, callback) -> callback()
      .call (val, callback) -> setImmediate ->
        callback Error 'Catchme'
        setImmediate -> callback Error 'Catchme'
      .error (err) ->
        err.errors.length.should.eql 3
        err.errors[0].message.should.eql 'Catchme'
        next()
      .next ->
        false.should.be.true()
