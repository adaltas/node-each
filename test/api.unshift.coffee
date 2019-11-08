
each = require '../src'

describe 'unshift', ->

  it 'accept array elements', (next) ->
    each()
    .unshift('hello')
    .unshift('each')
    .call (item, index, callback) ->
      item.should.eql 'each' if index is 0
      callback()
    .next (err, count) ->
      should.not.exist err
      count.should.eql 2
      next()

  it 'accept key value elements', (next) ->
    each()
    .unshift('hello', 'each')
    .unshift('youre', 'welcome')
    .call (key, value, callback) ->
      value.should.eql 'welcome' if key is 'youre'
      callback()
    .next (err, count) ->
      should.not.exist err
      count.should.eql 2
      next()

  it 'should place the next element', (next) ->
    last = null
    e = each(['a','b','c'])
    .call (value, callback) ->
      if value is 'a'
        e.unshift 'aa'
      if last is 'a'
        value.should.eql 'aa'
      if last is 'aa'
        value.should.eql 'b'
      last = value
      callback()
    .next (err, count) ->
      should.not.exist err
      count.should.eql 4
      next()
