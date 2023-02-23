
import each from '../lib/index.js'

describe 'options.flatten', ->
      
  it 'value `true` in constructor', ->
    each [
      'a'
      ['b', 'c'],
      ['d', ['e', ['f', [ 'g' ]]]]
    ], {flatten: true}
    .should.be.resolvedWith [
      'a',
      'b', 'c',
      'd', 'e', 'f', 'g'
    ]
      
  it 'value `false` in constructor', ->
    each [
      'a'
      ['b', 'c']
      ['d', ['e', ['f', [ 'g' ]]]]
    ], {flatten: false}
    .should.be.resolvedWith [
      'a',
      ['b', 'c']
      ['d', ['e', ['f', [ 'g' ]]]]
    ]
          
  it 'value `1` in constructor', ->
    each [
      'a'
      ['b', 'c']
      ['d', ['e', ['f', [ 'g' ]]]]
    ], {flatten: 1}
    .should.be.resolvedWith [
      'a',
      'b', 'c',
      'd', ['e', ['f', [ 'g' ]]]
    ]
  
