
should = require 'should'
each = if process.env.EACH_COV then require '../lib-cov/each' else require '../lib/each'

describe 'Sequential', ->
  it 'should run nothing 10 times', (next) ->
    started = ended = 0
    each()
    .parallel(null)
    .times(10)
    .on 'item', (element, index, next) ->
      # Check provided values
      started.should.eql ended
      should.not.exist element
      index.should.eql 0
      started++
      setTimeout ->
        ended++
        started.should.eql ended
        next()
      , 10
    .on 'end', ->
      started.should.eql 10
      next()
  it 'should run an array 10 times', (next) ->
    started = ended = 0
    data = ['a', 'b', 'c']
    each(data)
    .parallel(null)
    .times(10)
    .on 'item', (element, index, next) ->
      # Check provided values
      started.should.eql ended
      element.should.eql data[Math.floor started / 10]
      index.should.eql Math.floor started / 10
      started++
      setTimeout ->
        ended++
        started.should.eql ended
        next()
      , 10
    .on 'end', ->
      started.should.eql 30
      next()

describe 'Parallel', ->
  it 'should run nothing 10 times', (next) ->
    started = ended = 0
    each()
    .parallel(true)
    .times(10)
    .on 'item', (element, index, next) ->
      started.should.eql 0
      ended.should.eql 0
      process.nextTick -> started++
      setTimeout ->
        ended++
        started.should.eql 10
        next()
      , 10
    .on 'end', ->
      started.should.eql 10
      next()
  it 'should run an array 10 times', (next) ->
    started = ended = 0
    each(['a', 'b', 'c'])
    .parallel(true)
    .times(10)
    .on 'item', (element, index, next) ->
      started.should.eql 0
      ended.should.eql 0
      process.nextTick -> started++
      setTimeout ->
        ended++
        started.should.eql 30
        next()
      , 10
    .on 'end', ->
      started.should.eql 30
      next()

describe 'Concurrent', ->
  it 'should run nothing 10 times', (next) ->
    started = ended = 0
    runnings = []
    interval = null
    interval = setInterval ->
      running = started - ended
      runnings[running] ?= 0
      runnings[running]++
    , 10
    each()
    .parallel(3)
    .times(10)
    .on 'item', (element, index, next) ->
      process.nextTick -> started++
      setTimeout ->
        ended++
        next()
      , 100
    .on 'end', ->
      clearInterval interval
      (
        (typeof runnings[0] is 'undefined' or runnings[0] is 1) and
        (runnings[1] >= 9 and runnings[1] <= 11) and
        (typeof runnings[2] is 'undefined' or runnings[2] is 1) and
        (runnings[3] >= 26 and runnings[3] <= 28)
      ).should.be.ok
      started.should.eql 10
      next()
  it 'should run an array 10 times', (next) ->
    started = ended = 0
    each(['a', 'b', 'c'])
    .parallel(3)
    .times(10)
    .on 'item', (element, index, next) ->
      started++
      setTimeout ->
        running = started - ended
        total = 10 * 3
        if started is 30
        then running.should.eql started - ended
        else running.should.eql 3
        ended++
        next()
      , 100
    .on 'end', ->
      ended.should.eql 30
      next()