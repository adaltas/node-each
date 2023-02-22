
import each from '../src/index.coffee'

describe 'api.handler', ->
  
  it 'handler return a value', ->
    result = await each [2,4,6], (i) -> i + 1
    result.should.eql [3,5,7]
  
