
each = require '../src'

describe 'push', ->

  it 'accept array elements', (next) ->
    each()
    .push('hello')
    .push('each')
    .call (item, index, callback) ->
      item.should.eql 'hello' if index is 0
      callback()
    .error next
    .next (count) ->
      count.should.eql 2
      next()

  it 'accept key value elements', (next) ->
    each()
    .push('hello', 'each')
    .push('youre', 'welcome')
    .call (key, value, callback) ->
      value.should.eql 'each' if key is 'hello'
      callback()
    .error next
    .next (count) ->
      count.should.eql 2
      next()
