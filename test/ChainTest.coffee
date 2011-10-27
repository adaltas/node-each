
assert = require 'assert'
each = require '../index'

module.exports = 
    'Chain # array': (next) ->
        current = 0
        each [
            {id: 1}
            {id: 2}
            {id: 3}
        ], (element, n) ->
            current++
            unless n
                assert.eql current, 4
                return next()
            assert.eql current, element.id
            setTimeout n, 100
    'Chain # object': (next) ->
        current = 0
        each
            id_1: 1
            id_2: 2
            id_3: 3
        , (key, value, n) ->
            current++
            unless n
                assert.eql current, 4
                return next()
            assert.eql "id_#{current}", key
            assert.eql current, value
            setTimeout n, 100
    'Chain # undefined': (next) ->
        current = 0
        each undefined, (element, n) ->
            current++
            unless n
                assert.eql current, 2
                return next()
            assert.eql undefined, element
            setTimeout n, 100
    'Chain # null': (next) ->
        current = 0
        each null, (element, n) ->
            current++
            unless n
                assert.eql current, 2
                return next()
            assert.eql null, element
            setTimeout n, 100
    'Chain # string': (next) ->
        current = 0
        each 'id_1', (element, n) ->
            current++
            unless n
                assert.eql current, 2
                return next()
            assert.eql "id_1", element
            setTimeout n, 100
    'Chain # number': (next) ->
        current = 0
        each 3.14, (element, n) ->
            current++
            unless n
                assert.eql current, 2
                return next()
            assert.eql 3.14, element
            setTimeout n, 100
        
