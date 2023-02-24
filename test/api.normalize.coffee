
import each from '../lib/index.js'

describe 'api.normalize', ->
  
  it 'validation', ->
    (->
      each(new Promise( () => {}))
    ).should.throw 'Invalid argument: argument at position 0 must be one of array, object, function, boolean or number, got {}'
  
  it '0 arg, is a promise', ->
    each()
    .should.be.a.Promise()
      
  it 'multi args, merge items', ->
    result = await each([1,2,3], [4,5,6])
    result.should.eql [1,2,3,4,5,6]
      
  it 'multi args, merge options', ->
    eacher = each(2, {pause: true}, (->), relax: true)
    eacher.options('concurrency').should.eql 2
    eacher.options('pause').should.eql true
    eacher.options('handler').should.eql (->)
    eacher.options('relax').should.eql true
  
  it '1 arg, accept `items` argument', ->
    await each []
  
  it '1 arg, accept `option` argument', ->
    await (->
      e = each true
      e.options('concurrency').should.eql -1
      await e
    )()
    await (->
      e = each 2
      e.options('concurrency').should.eql 2
      await e
    )()
      
  it '2 args, accept `items, concurrency` argument', ->
    await (->
      e = each [], true
      e.options('concurrency').should.eql -1
      await e
    )()
    await (->
      e = each [], 2
      e.options('concurrency').should.eql 2
      await e
    )()
      
  it '2 args, accept `items, handler` argument', ->
    await (->
      e = each [], (-> 1)
      e.options('handler')().should.eql 1
      await e
    )()
      
  it '3 args, accept `items, concurrency, handler` argument', ->
    await (->
      e = each [], true, (-> 1)
      e.options('concurrency').should.eql -1
      e.options('handler')().should.eql 1
      await e
    )()
    await (->
      e = each [], 2, (-> 1)
      e.options('concurrency').should.eql 2
      e.options('handler')().should.eql 1
      await e
    )()
      
  it '3 args, accept `items, handler, concurrency` argument', ->
    await (->
      e = each [], (-> 1), true
      e.options('handler')().should.eql 1
      e.options('concurrency').should.eql -1
      await e
    )()
    await (->
      e = each [], (-> 1), 2
      e.options('handler')().should.eql 1
      e.options('concurrency').should.eql 2
      await e
    )()
