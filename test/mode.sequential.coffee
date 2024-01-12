
import each from '../lib/index.js'

describe 'mode.sequential', ->

  it 'list of functions', ->
    stacks = start: [], end: []
    item = (index, timeout) -> ->
      stacks.start.push(index)
      new Promise (resolve) -> setTimeout ->
        stacks.end.push(index) and resolve(index)
      , timeout
    result = await each [
      item(1, 20)
      item(2, 10)
    ], 1
    result.should.eql [1, 2]
    stacks.start.should.eql [1, 2]
    stacks.end.should.eql [1, 2]

  it 'ordered like Promise.all', ->
    item = (index, timeout) ->
      new Promise (resolve) -> setTimeout ->
        resolve(index)
      , timeout
    result = 
      each: await each [
        item(1, 20)
        item(2, 10)
      ], 1
      all: await Promise.all [
        item(1, 20)
        item(2, 10)
      ]
    result.each.should.eql result.all
    
  it 'promise handler with multiple items', ->
    count = 0
    running = 0
    await each [
      {id: 1}, {id: 2}, {id: 3},
      {id: 4}, {id: 5}, {id: 6},
      {id: 7}, {id: 8}, {id: 9}
    ], (item, index, callback) ->
      count++
      running++
      running.should.eql 1
      new Promise (resolve) ->
        running.should.eql 1
        setTimeout ->
          running.should.eql 1
          running--
          resolve()
        , 20
    count.should.eql 9
  
  it 'sync handler with multiple items', ->
    count = 0
    running = 0
    await each [
      {id: 1}, {id: 2}, {id: 3},
      {id: 4}, {id: 5}, {id: 6},
      {id: 7}, {id: 8}, {id: 9}
    ], (item, index, callback) ->
      index.should.eql index
      count++
      item.id.should.eql count
    count.should.eql 9
