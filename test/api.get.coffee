
import each from '../lib/index.js'

describe 'api.get', ->
      
  it '0 arg, return all options', ->
    each()
    .get().should.match
      concurrency: 1
      flatten: 0
      pause: false
      relax: false
