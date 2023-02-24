
import each from '../lib/index.js'

describe 'api.pause', ->
  
  it 'timing', ->
    stack = []
    scheduler = each()
    prom1 = scheduler.call -> new Promise (resolve) ->
      stack.push 1
      resolve 1
    prom1 = scheduler.call -> new Promise (resolve) ->
      stack.push 1
      resolve 1
    scheduler.pause()
    prom2 = scheduler.call -> new Promise (resolve) ->
      stack.push 2
      resolve 2
    stack.length.should.eql 0
    setTimeout ->
      stack.length.should.eql 0
      scheduler.resume()
    , 50
    result = await Promise.all [prom1, prom2]
    stack.length.should.eql 3
