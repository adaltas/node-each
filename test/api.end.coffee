
import each from '../lib/index.js'

describe 'api.end', ->
          
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
          
    it 'error is rejected by the promise', ->
      scheduler = each [
        new Promise (resolve) -> setTimeout (-> resolve 1), 10
        new Promise (resolve) -> setTimeout (-> resolve 2), 100
        new Promise (resolve) -> setTimeout (-> resolve 3), 100
      ]
      setTimeout (->
        scheduler.end(new Error('closing'))
      ), 20
      scheduler.should.be.rejectedWith 'closing'
            
    it 'cannot call push when closed with an error', ->
      scheduler = each()
      await scheduler.call () => 1
      scheduler.end(new Error('closing'))
      (->
        scheduler.call () => 2
      ).should.throw 'EACH_CLOSED: cannot schedule new items when closed.'
  
    it 'pass error while in pause', ->
      stack = []
      eacher = each pause: true
      eacher.call([1, 2]).then ->
        stack.push 2
      eacher.then ->
        stack.push 1
      new Promise (resolve, reject) ->
        setTimeout ->
          eacher.end new Error 'catch me'
          .then ->
            reject new Error 'oh no'
          .catch (err) ->
            err.message.should.eql 'catch me'
            stack.should.eql []
            resolve()
          .catch reject
        , 20
    
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
      eacher.call([1, 2]).then (value) ->
        stack.push value
      eacher.then (value) ->
        stack.push value
      new Promise (resolve, reject) ->
        setTimeout ->
          try
            await eacher.end()
            stack.should.eql [undefined, undefined]
            resolve()
          catch err then reject err
        , 20
    
    it 'end reject error when provided', ->
      stack = []
      eacher = each pause: true
      eacher.call([1, 2]).catch (err) ->
        stack.push err
      eacher.catch (err) ->
        stack.push err
      new Promise (resolve, reject) ->
        setTimeout ->
          try
            await eacher.end Error 'catchme'
            reject Error 'oh no'
          catch err
            err.message.should.eql 'catchme'
            stack.should.match [
              Error 'catchme'
              Error 'catchme'
            ]
            resolve()
        , 20
