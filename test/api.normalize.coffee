
import each from '../src/index.coffee'

describe 'api.normalize', ->
  
  it '0 arg, is a promise', ->
    each()
    .should.be.a.Promise()
      
  it 'multi args, merge items', ->
    result = await each([1,2,3], [4,5,6])
    result.should.eql [1,2,3,4,5,6]
      
  it 'multi args, merge options', ->
    each(2, {pause: true}, (->), relax: true)
    .get().should.eql
      concurrency: 2
      pause: true
      handler: (->)
      relax: true
  
  it '1 arg, accept `items` argument', ->
    await each []
  
  it '1 arg, accept `option` argument', ->
    await (->
      e = each true
      e.get('concurrency').should.eql -1
      await e
    )()
    await (->
      e = each 2
      e.get('concurrency').should.eql 2
      await e
    )()
      
  it '2 args, accept `items, concurrency` argument', ->
    await (->
      e = each [], true
      e.get('concurrency').should.eql -1
      await e
    )()
    await (->
      e = each [], 2
      e.get('concurrency').should.eql 2
      await e
    )()
      
  it '2 args, accept `items, handler` argument', ->
    await (->
      e = each [], (-> 1)
      e.get('handler')().should.eql 1
      await e
    )()
      
  it '3 args, accept `items, concurrency, handler` argument', ->
    await (->
      e = each [], true, (-> 1)
      e.get('concurrency').should.eql -1
      e.get('handler')().should.eql 1
      await e
    )()
    await (->
      e = each [], 2, (-> 1)
      e.get('concurrency').should.eql 2
      e.get('handler')().should.eql 1
      await e
    )()
      
  it '3 args, accept `items, handler, concurrency` argument', ->
    await (->
      e = each [], (-> 1), true
      e.get('handler')().should.eql 1
      e.get('concurrency').should.eql -1
      await e
    )()
    await (->
      e = each [], (-> 1), 2
      e.get('handler')().should.eql 1
      e.get('concurrency').should.eql 2
      await e
    )()
