
import each from '../lib/index.js'

describe 'api.end', ->
  
  it 'wait for running items before resolution', ->
    stack = []
    handler = (id) ->
      stack.push "#{id}:start"
      new Promise (resolve) ->
        setTimeout ->
          stack.push "#{id}:end"
          resolve()
        , 20
    n = each(-1)
    n.call -> handler 1
    n.call -> handler 2 
    n.call -> handler 3
    n.concurrency 1
    n.call -> handler 4
    n.call -> handler 5 
    n.call -> handler 6
    n.concurrency -1
    n.call -> handler 7
    n.call -> handler 8 
    n.call -> handler 9
    await n.end()
    stack.should.eql [
      '1:start', '2:start', '3:start'
      '1:end', '2:end', '3:end'
      '4:start', '4:end'
      '5:start', '5:end'
      '6:start', '6:end'
      '7:start', '8:start', '9:start'
      '7:end', '8:end', '9:end'
    ]
          
  it 'scheduled items are handled and root is resolved', ->
    scheduler = each [
      new Promise (resolve) -> setTimeout (-> resolve 1), 10
      new Promise (resolve) -> setTimeout (-> resolve 2), 100
      new Promise (resolve) -> setTimeout (-> resolve 3), 100
    ], true
    setTimeout (->
      scheduler.end()
    ), 20
    result = await scheduler
    result.should.eql [1, 2, 3]
          
  it 'cannot call push when closed', ->
    scheduler = each()
    await scheduler.call () => 1
    scheduler.end()
    (->
      scheduler.call () => 2
    ).should.throw 'EACH_CLOSED: cannot schedule new items when closed.'
          
  it 'error in an item propaged to close', ->
    scheduler = each()
    scheduler.call -> new Promise (resolve, reject) -> setTimeout ->
      reject Error 'catchme'
    , 10
    scheduler.end()
    .should.be.rejectedWith 'catchme'

  describe 'options.force', ->
        
    it 'by default, after Initialisation', ->
      scheduler = each ['a', 'b', 'c']
      scheduler.end()
      result = await scheduler
      # Note, implementation might change
      result.should.eql ['a', 'b', 'c']
        
    it 'when active, after Initialisation', ->
      scheduler = each ['a', 'b', 'c']
      scheduler.end force: true
      result = await scheduler
      # Note, implementation might change
      result.should.eql [undefined, undefined, undefined]
    
    it 'by default, scheduled items are handled', ->
      scheduler = each [
        new Promise (resolve) -> setTimeout (-> resolve 1), 10
        new Promise (resolve) -> setTimeout (-> resolve 2), 100
        new Promise (resolve) -> setTimeout (-> resolve 3), 100
      ]
      setTimeout (->
        scheduler.end()
      ), 20
      result = await scheduler
      result.should.eql [1, 2, 3]
        
    it 'when active, unscheduled items are not handled', ->
      scheduler = each [
        new Promise (resolve) -> setTimeout (-> resolve 1), 10
        new Promise (resolve) -> setTimeout (-> resolve 2), 100
        new Promise (resolve) -> setTimeout (-> resolve 3), 100
      ]
      setTimeout (->
        scheduler.end force: true
      ), 20
      result = await scheduler
      result.should.eql [1, 2, undefined]
  
  describe 'options.error', ->
          
    it 'when new items are to be scheduled', ->
      scheduler = each [
        new Promise (resolve) -> setTimeout (-> resolve 1), 10
        new Promise (resolve) -> setTimeout (-> resolve 2), 100
        new Promise (resolve) -> setTimeout (-> resolve 3), 100
      ]
      setTimeout (->
        scheduler.end(new Error('closing'))
      ), 20
      scheduler.should.be.rejectedWith 'closing'
              
    it 'when no new items are to be scheduled', ->
      scheduler = each [
        new Promise (resolve) -> setTimeout (-> resolve 1), 10
        new Promise (resolve) -> setTimeout (-> resolve 2), 100
        new Promise (resolve) -> setTimeout (-> resolve 3), 100
      ]
      setTimeout (->
        scheduler.end(new Error('closing'))
      ), 200
      scheduler.should.be.resolvedWith [1, 2, 3]
            
    it 'cannot call push when closed with an error', ->
      scheduler = each()
      await scheduler.call () => 1
      scheduler.end(new Error('closing'))
      (->
        scheduler.call () => 2
      ).should.throw 'EACH_CLOSED: cannot schedule new items when closed.'
    
    it 'has no effect if each.relax is active', ->
      scheduler = each [
        new Promise (resolve) -> setTimeout (-> resolve 1), 10
        new Promise (resolve) -> setTimeout (-> resolve 2), 100
        new Promise (resolve) -> setTimeout (-> resolve 3), 100
      ], relax: true
      setTimeout (->
        scheduler.end(new Error('closing'))
      ), 20
      scheduler.should.be.resolvedWith [ 1, 2, 3 ]

  describe 'state.pause', ->

    it 'end resolve as undefined if not error', ->
      stack = []
      eacher = each pause: true
      eacher.call([1, 2])
      .then (value) -> stack.push value
      eacher
      .then (value) -> stack.push value
      new Promise (resolve, reject) ->
        setTimeout ->
          try
            await eacher.end()
            stack.should.eql [undefined, undefined]
            resolve()
          catch err then reject err
        , 20
    
    it 'end reject error when provided', ->
      stack = resolve: [], reject: []
      eacher = each pause: true
      eacher.call([1, 2])
      .then (value) -> stack.resolve.push value
      .catch (err) -> stack.reject.push err.message
      eacher
      .then (value) -> stack.resolve.push value
      .catch (err) -> stack.reject.push err.message
      new Promise (resolve, reject) ->
        setTimeout ->
          try
            await eacher.end Error 'catchme'
            reject Error 'ohno'
          catch err
            err.message.should.eql 'catchme'
            stack.resolve.should.eql []
            stack.reject.should.match ['catchme', 'catchme']
            resolve()
        , 20
