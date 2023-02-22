
import each from '../lib/index.js'

describe 'throttle', ->
  
  describe 'api', ->
  
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
        
    it 'resolve after resume with multiple pause', ->
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
  
  describe 'time validation', ->
  
    it 'pause in options', ->
      stack = []
      scheduler = each pause: true
      prom1 = scheduler.call -> new Promise (resolve) ->
        stack.push 1
        resolve 1
      prom2 = scheduler.call -> new Promise (resolve) ->
        stack.push 2
        resolve 2
      setTimeout ->
        stack.length.should.eql 0
        scheduler.resume()
      , 50
      result = await Promise.all [prom1, prom2]
      stack.length.should.eql 2
    
    it 'pause as a function', ->
      stack = []
      scheduler = each()
      prom1 = scheduler.call -> new Promise (resolve) ->
        stack.push 1
        resolve 1
      scheduler.pause()
      prom2 = scheduler.call -> new Promise (resolve) ->
        stack.push 2
        resolve 2
      setTimeout ->
        stack.length.should.eql 1
        scheduler.resume()
      , 50
      result = await Promise.all [prom1, prom2]
      stack.length.should.eql 2
