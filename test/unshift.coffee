
should = require 'should'
each = if process.env.EACH_COV then require '../lib-cov/each' else require '../lib/each'

describe 'Unshift', ->

  it 'accept array elements', (next) ->
    each()
    .unshift('hello')
    .unshift('each')
    .on 'item', (item, index, next) ->
      item.should.eql 'each' if index is 0
      next()
    .on 'end', (count) ->
      count.should.eql 2
      next()

  it 'accept key value elements', (next) ->
    each()
    .unshift('hello', 'each')
    .unshift('youre', 'welcome')
    .on 'item', (key, value, next) ->
      value.should.eql 'welcome' if key is 'youre'
      next()
    .on 'end', (count) ->
      count.should.eql 2
      next()
