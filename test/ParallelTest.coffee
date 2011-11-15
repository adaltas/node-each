
assert = require 'assert'
each = require '../index'

module.exports = 
    'Parallel # array': (next) ->
        current = 0
        each( [{id: 1}, {id: 2}, {id: 3}], true )
        .on 'data', (n, element, index) ->
            assert.eql current, index
            current++
            assert.eql current, element.id
            setTimeout n, 100
        .on 'end', ->
            assert.eql current, 3
            next()
    'Parallel # array # send error # no end callback': (next) ->
        current = 0
        each( [{id: 1}, {id: 2}, {id: 3}, {id: 4}], true )
        .on 'data', (n, element, index) ->
            assert.eql current, index
            current++
            if element.id is 1 or element.id is 3
                n( new Error "Testing error in #{element.id}" )
            else setTimeout n, 100
        .on 'error', (err, errs) ->
            assert.eql '2 error(s)', err.message
            assert.eql 2, errs.length
            assert.eql 'Testing error in 1', errs[0].message
            assert.eql 'Testing error in 3', errs[1].message
            return next()
    'Parallel # object': (next) ->
        current = 0
        each( {id_1: 1, id_2: 2, id_3: 3}, true )
        .on 'data', (n, key, value) ->
            current++
            assert.eql "id_#{current}", key
            assert.eql current, value
            setTimeout n, 100
        .on 'end', (err) ->
            assert.eql current, 3
            next()
    'Parallel # undefined': (next) ->
        current = 0
        each( undefined, true )
        .on 'data', (n, element, index) ->
            assert.eql current, index
            current++
            assert.eql undefined, element
            setTimeout n, 100
        .on 'end', ->
            assert.eql current, 1
            next()
    'Parallel # null': (next) ->
        current = 0
        each( null, true )
        .on 'data', (n, element, index) ->
            assert.eql current, index
            current++
            assert.eql null, element
            setTimeout n, 100
        .on 'end', ->
            assert.eql current, 1
            next()
    'Parallel # string': (next) ->
        current = 0
        each( 'id_1', true )
        .on 'data', (n, element, index) ->
            assert.eql current, index
            current++
            assert.eql "id_1", element
            setTimeout n, 100
        .on 'end', ->
            assert.eql current, 1
            next()
    'Parallel # number': (next) ->
        current = 0
        each(3.14, true)
        .on 'data', (n, element, index) ->
            assert.eql current, index
            current++
            assert.eql 3.14, element
            setTimeout n, 100
        .on 'end', ->
            assert.eql current, 1
            next()
    'Parallel # function': (next) ->
        current = 0
        source = (c) -> c()
        each(source, true)
        .on 'data', (n, element, index) ->
            assert.eql current, index
            current++
            assert.eql typeof element, 'function'
            element n
        .on 'end', ->
            assert.eql current, 1
            next()
        
