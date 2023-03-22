
import each from '../lib/index.js'

describe 'options.fluent', ->
      
  it 'call', ->
    scheduler = each().call(1)
    should.exist(scheduler.options)
    scheduler = each(fluent: true).call(1)
    should.exist(scheduler.options)
    scheduler = each(fluent: false).call(1)
    should.not.exist(scheduler.options)
