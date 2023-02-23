
import each from '../lib/index.js'

describe 'api.end', ->
      
  it 'call end after Initialisation', ->
    scheduler = each ['a', 'b', 'c']
    scheduler.end()
    result = await scheduler
    result.should.eql [undefined, undefined, undefined]
          
  it 'scheduled items are handled', ->
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
          
  it 'unscheduled items are not handled', ->
    scheduler = each [
      new Promise (resolve) -> setTimeout (-> resolve 1), 10
      new Promise (resolve) -> setTimeout (-> resolve 2), 100
      new Promise (resolve) -> setTimeout (-> resolve 3), 100
    ]
    setTimeout (->
      scheduler.end()
    ), 20
    result = await scheduler
    result.should.eql [1, 2, undefined]
          
  it 'cannot call push when closed', ->
    scheduler = each()
    await scheduler.call () => 1
    scheduler.end()
    (->
      scheduler.call () => 2
    ).should.throw 'EACH_CLOSED: cannot schedule new items when closed.'
  
  describe 'error', ->
          
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
