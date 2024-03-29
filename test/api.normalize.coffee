
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
    eacher = each(2, (->), relax: true)
    await eacher.options('concurrency').should.be.resolvedWith 2
    await eacher.options('pause').should.be.resolvedWith false
    await eacher.options('handler').should.be.resolvedWith (->)
    await eacher.options('relax').should.be.resolvedWith true
  
  it '1 arg, accept `items` argument', ->
    await each []
  
  it '1 arg, accept `option` argument', ->
    await (->
      e = each true
      e.options('concurrency').should.be.resolvedWith -1
      await e
    )()
    await (->
      e = each 2
      e.options('concurrency').should.be.resolvedWith 2
      await e
    )()
      
  it '2 args, accept `items, concurrency` argument', ->
    await (->
      e = each [], true
      e.options('concurrency').should.be.resolvedWith -1
      await e
    )()
    await (->
      e = each [], 2
      e.options('concurrency').should.be.resolvedWith 2
      await e
    )()
      
  it '2 args, accept `items, handler` argument', ->
    each [], (-> 42)
    .options('handler').then (handler) ->
      handler().should.equal 42
      
  it '3 args, accept `items, concurrency, handler` argument', ->
    await (->
      e = each [], true, (-> 42)
      await e.options('concurrency').should.be.resolvedWith -1
      await e.options('handler').then (handler) ->
        handler().should.equal 42
      await e
    )()
    await (->
      e = each [], 2, (-> 42)
      await e.options('concurrency').should.be.resolvedWith 2
      await e.options('handler').then (handler) ->
        handler().should.equal 42
      await e
    )()
      
  it '3 args, accept `items, handler, concurrency` argument', ->
    await (->
      e = each [], (-> 42), true
      await e.options('concurrency').should.be.resolvedWith -1
      await e.options('handler').then (handler) ->
        handler().should.equal 42
      await e
    )()
    await (->
      e = each [], (-> 42), 2
      await e.options('concurrency').should.be.resolvedWith 2
      await e.options('handler').then (handler) ->
        handler().should.equal 42
      await e
    )()
