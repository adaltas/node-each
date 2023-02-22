
import each from '../src/index.coffee'

describe 'api.items', ->
  
  describe 'values', ->
  
      it 'pass an empty list', ->
        # Constructor
        result = await each []
        result.should.eql []
        # Push
        result = await each().push []
        result.should.eql []
      
      it 'pass a value', ->
        # Constructor
        result = await each ['ok']
        result.should.eql ['ok']
        # Push
        result = await each().push ['ok']
        result.should.eql ['ok']
      
      it 'pass a function which return a value', ->
        # Constructor
        result = await each [-> 'ok']
        result.should.eql ['ok']
        # Push
        result = await each().push [-> 'ok']
        result.should.eql ['ok']
          
  describe 'functions', ->
  
    it 'pass a function which return a promise which resolves immediatly', ->
      # Constructor
      result = await each [
        -> new Promise (resolve, reject) -> resolve 'ok'
      ]
      result.should.eql ['ok']
      # Push
      result = await each().push [
        -> new Promise (resolve, reject) -> resolve 'ok'
      ]
      result.should.eql ['ok']
    
    it 'pass a function which return a promise which resolves in next tick', ->
      # Constructor
      result = await each [
        -> new Promise (resolve, reject) -> setImmediate resolve 'ok'
      ]
      result.should.eql ['ok']
      # Push
      result = await each().push [
        -> new Promise (resolve, reject) -> setImmediate resolve 'ok'
      ]
      result.should.eql ['ok']
        
  describe 'promise', ->
  
    it 'pass a promise which resolves immediatly', ->
      # Constructor
      result = await each [
        new Promise (resolve, reject) -> resolve 'ok'
      ]
      result.should.eql ['ok']
      # Push
      result = await each().push [
        new Promise (resolve, reject) -> resolve 'ok'
      ]
      result.should.eql ['ok']
    
    it 'pass a promise which resolves in next tick', ->
      # Constructor
      result = await each [
        new Promise (resolve, reject) -> setImmediate resolve 1
        new Promise (resolve, reject) -> resolve 2
      ]
      result.should.eql [1, 2]
      # Push
      result = await each().push [
        new Promise (resolve, reject) -> setImmediate resolve 1
        new Promise (resolve, reject) -> resolve 2
      ]
      result.should.eql [1, 2]
    
  
