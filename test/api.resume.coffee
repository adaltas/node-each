
import each from '../lib/index.js'

describe 'api.normalize', ->
  
  it 'return a promise', ->
    each()
    .resume()
    .should.be.a.Promise()
  
  it 'may be call over an unpaused status', ->
    eacher = each pause: true
    eacher.resume()
    eacher.resume()
    await eacher.end()
