
import each from '../lib/index.js'

describe 'api.handler', ->
  
  it 'handle a scalar value', ->
    result = await each [2,4,6], (i) -> i + 1
    result.should.eql [3,5,7]
  
  it 'handle a function', ->
    result = await each [
      () -> 'a'
      () -> new Promise (resolve) -> resolve 'b'
      () -> new Promise (resolve) -> setImmediate -> resolve 'c'
    ], (i) ->
      "> #{await i.call()}"
    result.should.eql ['> a', '> b', '> c']
  
  it 'handle promises', ->
    result = await each [
      new Promise (resolve) -> resolve 'a'
      new Promise (resolve) -> setImmediate -> resolve 'b'
    ], (i) ->
      "> #{await i}"
    result.should.eql ['> a', '> b']
  
