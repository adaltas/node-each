
assert = require 'assert'
each = require '../index'

module.exports = 
    'Chain # array # no end callback': (next) ->
        current = 0
        each [
            {id: 1}
            {id: 2}
            {id: 3}
        ], true, (element, n) ->
            unless n
                assert.eql current, 3
                return next()
            current++
            assert.eql current, element.id
            setTimeout n, 100
    'Chain # array # end callback': (next) ->
        current = 0
        each [
            {id: 1}
            {id: 2}
            {id: 3}
        ], true, (element, n) ->
            unless n
                assert.eql current, 3
                return next()
            current++
            assert.eql current, element.id
            setTimeout n, 100
    'Chain # object # no end callback': (next) ->
        current = 0
        each
            id_1: 1
            id_2: 2
            id_3: 3
        , true
        , (key, value, n) ->
            current++
            assert.eql "id_#{current}", key
            assert.eql current, value
            setTimeout n, 100
        , (err) ->
            assert.eql current, 3
            return next()
    'Chain # object # end callback': (next) ->
        current = 0
        each
            id_1: 1
            id_2: 2
            id_3: 3
        , true
        , (key, value, n) ->
            current++
            assert.eql "id_#{current}", key
            assert.eql current, value
            n()
        , (err) ->
            assert.eql current, 3
            return next()
    'Chain # undefined': (next) ->
        current = 0
        each undefined, true, (element, n) ->
            current++
            unless n
                assert.eql current, 2
                return next()
            assert.eql undefined, element
            setTimeout n, 100
    'Chain # null': (next) ->
        current = 0
        each null, true, (element, n) ->
            current++
            unless n
                assert.eql current, 2
                return next()
            assert.eql null, element
            setTimeout n, 100
    'Chain # string': (next) ->
        current = 0
        each 'id_1', true, (element, n) ->
            current++
            unless n
                assert.eql current, 2
                return next()
            assert.eql "id_1", element
            setTimeout n, 100
    'Chain # number': (next) ->
        current = 0
        each 3.14, true, (element, n) ->
            current++
            unless n
                assert.eql current, 2
                return next()
            assert.eql 3.14, element
            setTimeout n, 100
        
