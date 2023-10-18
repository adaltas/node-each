
import each from '../lib/index.js'

describe 'state.running', ->
      
  it 'default to `0`', ->
    scheduler = each()
    scheduler.state().running.should.eql 0
    await scheduler
      
  it 'back to `0` after execution', ->
    scheduler = each [
      -> new Promise (resolve) -> resolve 1
      -> new Promise (resolve) -> resolve 2
      -> new Promise (resolve) -> resolve 3
    ]
    await scheduler
    scheduler.state().running.should.eql 0
  