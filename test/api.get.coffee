
import each from '../lib/index.js'

describe 'api.get', ->
  
  it 'validation', ->
    (->
      each().get(1,2,3)
    ).should.throw 'EACH_GET_ARGUMENT_LENGTH: `get` expect one or two arguments, got 3'
      
  it '0 arg, return all options', ->
    each()
    .get().should.match
      concurrency: 1
      flatten: 0
      pause: false
      relax: false
