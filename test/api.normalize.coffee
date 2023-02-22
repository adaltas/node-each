
import each from '../src/index.coffee'

describe 'api.normalize', ->
  
  it '0 arg, is a promise', ->
    each()
    .should.be.a.Promise()
  
  it '1 arg, accept `elements` argument', ->
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
      
  it '2 args, accept `elements, concurrency` argument', ->
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
      
  it '2 args, accept `elements, handler` argument', ->
    await (->
      e = each [], (-> 1)
      e.get('handler')().should.eql 1
      await e
    )()
      
  it '3 args, accept `elements, concurrency, handler` argument', ->
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
      
  it '3 args, accept `elements, handler, concurrency` argument', ->
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
