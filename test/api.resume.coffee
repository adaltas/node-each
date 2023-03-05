
import each from '../lib/index.js'

describe 'api.resume', ->
  
  it 'return a promise', ->
    each()
    .resume()
    .should.be.a.Promise()
  
  it 'may be call over an unpaused status', ->
    eacher = each pause: true
    eacher.resume()
    eacher.resume()
    await eacher.end()
  
  describe 'resolution', ->
    
    it 'items resolve to an items', ->
      scheduler = each [1, 2, 3], pause: true
      promRoot = scheduler
      promCall = scheduler.call [4, 5, 6]
      scheduler.resume()
      result = await Promise.all [promRoot, promCall]
      result.should.eql [ [1, 2, 3], [4, 5, 6] ]
        
    it 'scalar item resolve to scalar item', ->
      # each only accept arrays at initialization
      # but call accept single items
      scheduler = each ['a'], pause: true
      promRoot = scheduler
      promCall = scheduler.call 'b'
      scheduler.resume()
      result = await Promise.all [promRoot, promCall]
      result.should.eql [ ['a'], 'b' ]
      
  describe 'throttling', ->
  
    it 'resolve before resume', ->
      eacher = each [
        {id: 1}, {id: 2}, {id: 3},
        {id: 4}, {id: 5}, {id: 6},
        {id: 7}, {id: 8}, {id: 9}
      ], 4, (item, index) ->
        if item.id is 2
          eacher.pause()
          setTimeout ->
            eacher.resume()
          , 100
      await eacher
    
    it 'resolve after resume', ->
      eacher = each [
        {id: 1}, {id: 2}, {id: 3},
        {id: 4}, {id: 5}, {id: 6},
        {id: 7}, {id: 8}, {id: 9}
      ], 4, (item, index) ->
        if item.id is 2
          eacher.pause()
          new Promise (resolve) ->
            setTimeout ->
              eacher.resume()
              resolve()
            , 100
      await eacher
        
    it 'resolve after resume with multiple pause/resume', ->
      eacher = each [
        {id: 1}, {id: 2}, {id: 3},
        {id: 4}, {id: 5}, {id: 6},
        {id: 7}, {id: 8}, {id: 9}
      ], 4, (item, index, callback) ->
        if item.id % 2 is 0
          eacher.pause()
          new Promise (resolve) ->
            setTimeout ->
              eacher.resume()
              resolve()
            , 10 * item.id
      await eacher
        
    it 'resolve before resume with multiple pause', ->
      eacher = each [
        {id: 1}, {id: 2}, {id: 3},
        {id: 4}, {id: 5}, {id: 6},
        {id: 7}, {id: 8}, {id: 9}
      ], 4, (item, index) ->
        if item.id % 2 is 0
          eacher.pause()
          setTimeout ->
            eacher.resume()
          , 10 * item.id
      await eacher
  
  describe 'error', ->
    
    it 'pass error while in pause', ->
      stack = []
      eacher = each pause: true
      eacher.call -> new Promise (resolve) -> setImmediate resolve 'before'
      eacher.call -> new Promise (resolve, reject) -> setImmediate reject new Error 'catchme'
      eacher.call -> new Promise (resolve) -> setImmediate resolve 'after'
      eacher.resume()
      .should.be.rejectedWith 'catchme'
      # await eacher.end()
