
import each from '../src/index.coffee'

describe 'mode.concurrent', ->
  
  it 'promise handler with multiple elements', ->
    count = 0
    await each [
      {id: 1}, {id: 2}, {id: 3}
    ], true, (element, index) ->
      new Promise (resolve) ->
        index.should.eql count
        count++
        element.id.should.eql count
        setTimeout resolve, 100
    count.should.eql 3
  
  it 'handle very large array', ->
    count = 0
    values = for i in [0..Math.pow(2, 14)] then Math.random()
    await each values, true, (element, i) ->
      new Promise (resolve) ->
        count++
        setTimeout resolve, 1
    count.should.eql values.length
      
  it 'element sync functions', ->
    count = 0
    running = 0
    test = ->
      running++
      running.should.be.above 0
      running.should.be.below 10
      new Promise (resolve) ->
        running.should.be.above 0
        running.should.be.below 10
        count++
        setTimeout ->
          running.should.be.above 0
          running.should.be.below 10
          running--
          resolve()
        , 20
    await each [
      test, test, test,
      test, test, test,
      test, test, test,
    ], true
    count.should.eql 9
    running.should.eql 0
    
