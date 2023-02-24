
import each from '../lib/index.js'

describe 'api.pause', ->
  
  it 'timing', ->
    stack = []
    scheduler = each()
    prom1 = scheduler.call -> new Promise (resolve) ->
      stack.push 1
      resolve 1
    prom2 = scheduler.call -> new Promise (resolve) ->
      stack.push 2
      resolve 2
    scheduler.pause()
    prom3 = scheduler.call -> new Promise (resolve) ->
      stack.push 3
      resolve 3
    stack.length.should.eql 0
    setTimeout ->
      stack.length.should.eql 0
      scheduler.resume()
    , 50
    await Promise.all [prom1, prom2, prom3]
    stack.length.should.eql 3
