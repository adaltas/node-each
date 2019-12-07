
each = require '../src'

describe 'api.queue', ->
  
  it 'without elements', (next) ->
    timeout = false
    queue = each()
    .parallel false
    .call (->)
    .queue()
    .next (err) ->
      timeout.should.be.true()
      (err is null).should.be.true()
      next err
    setTimeout ->
      timeout = true
      queue.close()
    , 200
      
  it 'with initial elements', (next) ->
    timeout = false
    results = []
    queue = each()
    .parallel false
    .push 'result_1'
    .push 'result_2'
    .call (result, callback) ->
      setImmediate ->
        results.push result
        callback()
    .queue()
    .next (err) ->
      timeout.should.be.true()
      (err is null).should.be.true()
      results.should.eql ['result_1', 'result_2']
      next err
    setTimeout ->
      timeout = true
      queue.close()
    , 200
      
  it 'with elements post-inserted', (next) ->
    timeout = false
    results = []
    queue = each()
    .parallel false
    .call (result, callback) ->
      setImmediate ->
        results.push result
        callback()
    .queue()
    .next (err) ->
      timeout.should.be.true()
      (err is null).should.be.true()
      results.should.eql ['result_1', 'result_2']
      next err
    setTimeout ( -> queue.push 'result_1' ), 50
    setTimeout ( -> queue.push 'result_2' ), 100
    setTimeout ->
      timeout = true
      queue.close()
    , 500
  
