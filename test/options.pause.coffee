
import each from '../lib/index.js'

describe 'options.pause', ->
      
  it 'each resolves on resume', ->
    stack = []
    scheduler = each pause: true
    scheduler.then ->
      stack.push 1
    new Promise (resolve) ->
      setTimeout ->
        stack.length.should.eql 0
        await scheduler.resume()
        stack.length.should.eql 1
        resolve()
      , 10

  it 'call resolve on resume', ->
    stack = []
    scheduler = each pause: true
    prom1 = scheduler.call -> new Promise (resolve) ->
      stack.push 1
      resolve 1
    prom2 = scheduler.call -> new Promise (resolve) ->
      stack.push 2
      resolve 2
    new Promise (resolve) ->
      setTimeout ->
        stack.length.should.eql 0
        await scheduler.resume()
        stack.length.should.eql 2
        resolve()
      , 50
  
  it 'each resolves before call on resume', ->
    stack = []
    eacher = each pause: true
    eacher.call([1, 2]).then ->
      stack.push 2
    eacher.then ->
      stack.push 1
    new Promise (resolve) ->
      setTimeout ->
        await eacher.resume()
        stack.should.eql [1, 2]
        resolve()
      , 20
  
  it 'each resolves before call on end', ->
    stack = []
    eacher = each pause: true
    eacher.call([1, 2]).then ->
      stack.push 2
    eacher.then ->
      stack.push 1
    new Promise (resolve) ->
      setTimeout ->
        await eacher.end()
        stack.should.eql [1, 2]
        resolve()
      , 20
