
assert = require 'assert'
each = require '../index'

module.exports = 
    'Sequential # array': (next) ->
        current = 0
        each( [ {id: 1}, {id: 2}, {id: 3} ] )
        .on 'data', (n, element, index) ->
            assert.eql current, index
            current++
            assert.eql current, element.id
            setTimeout n, 100
        .on 'end', ->
            assert.eql current, 3
            next()
    'Sequential # array # send error': (next) ->
        current = 0
        each( [ {id: 1}, {id: 2}, {id: 3} ] )
        .on 'data', (n, element, index) ->
            assert.eql current, index
            current++
            if element.id is 2
                n( new Error 'Testing error' )
            else setTimeout n, 100
        .on 'error', (err) ->
            assert.eql 'Testing error', err.message
            next()
    'Sequential # object': (next) ->
        current = 0
        each( {id_1: 1, id_2: 2, id_3: 3} )
        .on 'data', (n, key, value) ->
            current++
            assert.eql "id_#{current}", key
            assert.eql current, value
            setTimeout n, 100
        .on 'end', ->
            assert.eql current, 3
            next()
    'Sequential # undefined': (next) ->
        current = 0
        each( undefined )
        .on 'data', (n, element, index) ->
            assert.eql current, index
            current++
            assert.eql undefined, element
            setTimeout n, 100
        .on 'end', ->
            assert.eql current, 1
            next()
    'Sequential # null': (next) ->
        current = 0
        each( null )
        .on 'data', (n, element, index) ->
            assert.eql current, index
            current++
            assert.eql null, element
            setTimeout n, 100
        .on 'end', ->
            assert.eql current, 1
            next()
    'Sequential # string': (next) ->
        current = 0
        each( 'id_1' )
        .on 'data', (n, element, index) ->
            assert.eql current, index
            current++
            assert.eql "id_1", element
            setTimeout n, 100
        .on 'end', ->
            assert.eql current, 1
            next()
    'Sequential # number': (next) ->
        current = 0
        each( 3.14 )
        .on 'data', (n, element, index) ->
            assert.eql current, index
            current++
            assert.eql 3.14, element
            setTimeout n, 100
        .on 'end', ->
            assert.eql current, 1
            next()
    'Sequential # function': (next) ->
        current = 0
        source = (c) -> c()
        each(source)
        .on 'data', (n, element, index) ->
            assert.eql current, index
            current++
            assert.eql typeof element, 'function'
            element n
        .on 'end', ->
            assert.eql current, 1
            next()

