
each = require '../src'

describe 'times', ->
  
  describe 'sequential', ->
    
    it 'should run nothing 10 times', (next) ->
      started = ended = 0
      each()
      .parallel(null)
      .times(10)
      .call (element, index, callback) ->
        # Check provided values
        started.should.eql ended
        should.not.exist element
        index.should.eql 0
        started++
        setTimeout ->
          ended++
          started.should.eql ended
          callback()
        , 10
      .error next
      .next ->
        started.should.eql 10
        next()
        
    it 'should run an array 10 times', (next) ->
      started = ended = 0
      data = ['a', 'b', 'c']
      each(data)
      .parallel(null)
      .times(10)
      .call (element, index, callback) ->
        # Check provided values
        started.should.eql ended
        element.should.eql data[Math.floor started / 10]
        index.should.eql Math.floor started / 10
        started++
        setTimeout ->
          ended++
          started.should.eql ended
          callback()
        , 10
      .error next
      .next ->
        started.should.eql 30
        next()

  describe 'parallel', ->
    
    it 'should run nothing 10 times', (next) ->
      started = ended = 0
      each()
      .parallel(true)
      .times(10)
      .call (element, index, callback) ->
        started.should.eql 0
        ended.should.eql 0
        process.nextTick -> started++
        setTimeout ->
          ended++
          started.should.eql 10
          callback()
        , 10
      .error next
      .next ->
        started.should.eql 10
        next()
        
    it 'should run an array 10 times', (next) ->
      started = ended = 0
      each(['a', 'b', 'c'])
      .parallel(true)
      .times(10)
      .call (element, index, callback) ->
        started.should.eql 0
        ended.should.eql 0
        process.nextTick -> started++
        setTimeout ->
          ended++
          started.should.eql 30
          callback()
        , 10
      .error next
      .next ->
        started.should.eql 30
        next()

  describe 'concurrent', ->
    
    it 'should run nothing 10 times', (next) ->
      started = ended = 0
      each()
      .parallel(3)
      .times(10)
      .call (element, index, callback) ->
        started++
        setTimeout ->
          ended++
          started.should.be.above 2
          ended.should.be.above started - 3
          callback()
        , 100
      .error next
      .next ->
        started.should.eql 10
        next()
        
    it 'should run an array 10 times', (next) ->
      started = ended = 0
      each(['a', 'b', 'c'])
      .parallel(3)
      .times(10)
      .call (element, index, callback) ->
        started++
        setTimeout ->
          running = started - ended
          total = 10 * 3
          if started is 30
          then running.should.eql started - ended
          else running.should.eql 3
          ended++
          callback()
        , 100
      .error next
      .next ->
        ended.should.eql 30
        next()
