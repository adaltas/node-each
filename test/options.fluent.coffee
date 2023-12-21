
import each from '../lib/index.js'

describe 'options.fluent', ->
      
  it 'call is chainable by default', ->
    scheduler = each().call(1)
    should.exist(scheduler.options)
      
  it 'call is chainable if `true`', ->
    scheduler = each(fluent: true).call(1)
    should.exist(scheduler.options)
      
  it 'call is not chainable if `false`', ->
    scheduler = each(fluent: false).call(1)
    should.not.exist(scheduler.options)
