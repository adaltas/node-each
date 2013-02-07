
should = require 'should'
each = if process.env.EACH_COV then require '../lib-cov/each' else require '../lib/each'

describe 'Write', ->

  it 'accept array elements', (next) ->
    each()
    .write('hello')
    .write('each')
    .on 'item', (item, index, next) ->
      item.should.eql 'hello' if index is 0
      next()
    .on 'end', (count) ->
      count.should.eql 2
      next()

  it 'accept key value elements', (next) ->
    each()
    .write('hello', 'each')
    .write('youre', 'welcome')
    .on 'item', (key, value, next) ->
      value.should.eql 'each' if key is 'hello'
      next()
    .on 'end', (count) ->
      count.should.eql 2
      next()
