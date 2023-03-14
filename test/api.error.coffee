
import each from '../lib/index.js'

describe 'api.error', ->
  
  it 'items scheduled after are rejected', ->
    scheduler = each()
    scheduler.error Error 'catchme'
    scheduler
    .call [1, 2]
    .should.be.rejectedWith 'catchme'
      
  it 'items scheduled before are executed', ->
    stack = []
    scheduler = each [1]
    scheduler
    .then (value) -> stack.push value
    scheduler
    .call 2
    .then (value) -> stack.push value
    await scheduler.error Error 'catchme'
    stack.should.eql [ [1], 2]
    
  
  
