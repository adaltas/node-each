
import each from '../src/index.coffee'

describe 'mode.concurrent', ->
  
  it 'empty array', ->
    count = 0
    await each [], 4, (element, index) ->
      count++
    count.should.eql 0
  
  it 'promise handler with multiple elements', ->
    count = 0
    await each [
      {id: 1}, {id: 2}, {id: 3},
      {id: 4}, {id: 5}, {id: 6},
      {id: 7}, {id: 8}, {id: 9}
    ], 4, (element, index) ->
      new Promise (resolve) ->
        index.should.eql count
        count++
        element.id.should.eql count
        setTimeout resolve, 20
    count.should.eql 9
      
  it 'promise handler with one element', ->
    count = 0
    await each [ {id: 1} ], 4, (element, index) ->
      new Promise (resolve) ->
        index.should.eql count
        count++
        element.id.should.eql count
        setTimeout resolve, 20
    count.should.eql 1
      
  it 'sync handler', ->
    count = 0
    await each [
      {id: 1}, {id: 2}, {id: 3},
      {id: 4}, {id: 5}, {id: 6},
      {id: 7}, {id: 8}, {id: 9}
    ], 4, (element, index) ->
      index.should.eql count
      count++
      element.id.should.eql count
    count.should.eql 9
      
  it 'element sync functions', ->
    count = 0
    test = -> count++
    await each [
      test, test, test,
      test, test, test,
      test, test, test,
    ], 4
    count.should.eql 9
      
  it 'element sync functions', ->
    count = 0
    running = 0
    test = ->
      running++
      running.should.be.above 0
      running.should.be.below 5
      new Promise (resolve) ->
        running.should.be.above 0
        running.should.be.below 5
        count++
        setTimeout ->
          running.should.be.above 0
          running.should.be.below 5
          running--
          resolve()
        , 20
    await each [
      test, test, test,
      test, test, test,
      test, test, test,
    ], 4
    count.should.eql 9
    running.should.eql 0
      
  it 'handler with error thrown', ->
    count = 0
    test = ->
      count++
      throw Error 'catchme' if count is 6
      new Promise (resolve) ->
        setTimeout resolve, 20
    try
      await each [
        test, test, test,
        test, test, test,
        test, test, test,
      ], 4
    catch error
      error.message.should.eql 'catchme'
    finally
      count.should.eql 6
      
  it 'handler with error rejected', ->
    count = 0
    test = ->
      new Promise (resolve, reject) ->
        setTimeout ->
          count.should.be.below 6
          count++
          if count >= 4
          then reject Error 'catchme'
          else
            resolve()
        , 20
    try
      await each [
        test, test, test,
        test, test, test,
        test, test, test,
      ], 3
    catch error
      error.message.should.eql 'catchme'
    finally
      count.should.eql 4
