
import each from '../lib/index.js'

describe 'mode.concurrent', ->

  it 'list of functions', ->
    stacks = start: [], end: []
    item = (index, timeout) -> ->
      stacks.start.push(index)
      new Promise (resolve) -> setTimeout ->
        stacks.end.push(index) and resolve(index)
      , timeout
    result = await each [
      item(1, 40)
      item(2, 20)
      item(3, 50)
      item(4, 10)
    ], 2
    result.should.eql [1, 2, 3, 4]
    stacks.start.should.eql [1, 2, 3, 4]
    stacks.end.should.eql [2, 1, 4, 3]

  it 'ordered like Promise.all', ->
    item = (index, timeout) ->
      new Promise (resolve) -> setTimeout ->
        resolve(index)
      , timeout
    result = 
      each: await each [
        item(1, 20)
        item(2, 40)
        item(3, 10)
        item(4, 30)
      ], true
      all: await Promise.all [
        item(1, 20)
        item(2, 40)
        item(3, 10)
        item(4, 30)
      ]
    result.each.should.eql result.all
  
  it 'empty array', ->
    count = 0
    await each [], 4, (item, index) ->
      count++
    count.should.eql 0
  
  it 'promise handler with multiple items', ->
    count = 0
    await each [
      {id: 1}, {id: 2}, {id: 3},
      {id: 4}, {id: 5}, {id: 6},
      {id: 7}, {id: 8}, {id: 9}
    ], 4, (item, index) ->
      new Promise (resolve) ->
        index.should.eql count
        count++
        item.id.should.eql count
        setTimeout resolve, 20
    count.should.eql 9
      
  it 'promise handler with one item', ->
    count = 0
    await each [ {id: 1} ], 4, (item, index) ->
      new Promise (resolve) ->
        index.should.eql count
        count++
        item.id.should.eql count
        setTimeout resolve, 20
    count.should.eql 1
      
  it 'sync handler', ->
    count = 0
    await each [
      {id: 1}, {id: 2}, {id: 3},
      {id: 4}, {id: 5}, {id: 6},
      {id: 7}, {id: 8}, {id: 9}
    ], 4, (item, index) ->
      index.should.eql count
      count++
      item.id.should.eql count
    count.should.eql 9
      
  it 'item sync functions', ->
    count = 0
    test = -> count++
    await each [
      test, test, test,
      test, test, test,
      test, test, test,
    ], 4
    count.should.eql 9
      
  it 'item sync functions', ->
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
