
import each from '../lib/index.js'

describe 'api.options', ->
  
  it 'validation', ->
    (->
      each().options(1,2,3)
    ).should.throw 'EACH_OPTIONS_ARGUMENT_LENGTH: `options` expect one or two arguments, got 3'
      
  it '0 arg, return all options', ->
    each()
    .options().should.match
      concurrency: 1
      flatten: 0
      pause: false
      relax: false
    
  it '1 arg, get an options', ->
    each()
    .options('concurrency').should.equal 1
  
  it '2 args, set an options', ->
    each()
    .options('concurrency', 2)
    .options('concurrency').should.equal 2
