
import each from '../lib/index.js'

describe 'state.count', ->
      
  it 'default to `0`', ->
    scheduler = each()
    scheduler.state().count.should.eql 0
    await scheduler
      
  it 'default increment with handler execution', ->
    scheduler = each [
      -> new Promise (resolve) -> resolve 1
      -> new Promise (resolve) -> resolve 2
      -> new Promise (resolve) -> resolve 3
    ]
    await scheduler
    scheduler.state().count.should.eql 3
      
  it 'increment on error and stop incrementing after', ->
    scheduler = each [
      -> new Promise (resolve) -> resolve 1
      -> new Promise (resolve, reject) -> reject 2
      -> new Promise (resolve) -> resolve 3
    ]
    await scheduler.catch(->)
    scheduler.state().count.should.eql 2
  