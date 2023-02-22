
import each from '../lib/index.js'

describe 'mode.sequential', ->
    
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
        
  # describe 'multiple call error', ->
  # 
  #   it 'with end already thrown', ->
  #     # Nothing we can do here, end has been thrown and we can not wait for it
  #     # Catch the uncatchable
  #     lsts = process.listeners 'uncaughtException'
  #     process.removeAllListeners 'uncaughtException'
  #     process.on 'uncaughtException', (err) ->
  #       # Test
  #       ended.should.be.true()
  #       err.message.should.eql 'Multiple call detected'
  #       # Cleanup and finish
  #       process.removeAllListeners 'uncaughtException'
  #       for lst in lsts
  #         process.on 'uncaughtException', lst
  #       next()
  #     # Run the test
  #     ended = false
  #     each( [ 'a', 'b', 'c' ] )
  #     .parallel(1)
  #     .call (item, callback) ->
  #       callback()
  #       # We only want to generate one error
  #       return unless item is 'a'
  #       process.nextTick callback
  #     .next (err) ->
  #       ended = true
  # 
  #   it 'with end not yet thrown', ->
  #     ended = false
  #     each [ 'a', 'b', 'c' ]
  #     .parallel 1
  #     .call (item, callback) ->
  #       process.nextTick ->
  #         callback()
  #         # We only want to generate one error
  #         return unless item is 'a'
  #         process.nextTick callback
  #     .error (err) ->
  #       ended.should.be.false()
  #       err.message.should.eql 'Multiple call detected'
  #       next()
  #     .next ->
  #       ended = true
