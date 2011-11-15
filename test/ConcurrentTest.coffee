
assert = require 'assert'
each = require '../index'

module.exports = 
    'Concurrent # array # multiple elements # async callbacks': (next) ->
        current = 0
        source = [ {id: 1}, {id: 2}, {id: 3}, {id: 4}, {id: 5}, {id: 6}, {id: 7}, {id: 8}, {id: 9} ]
        each(source, 4)
        .on 'data', (n, element, index) ->
            assert.eql current, index
            current++
            assert.eql current, element.id
            setTimeout n, 100
        .on 'end', ->
            assert.eql current, 9
            setTimeout next, 100
    'Concurrent # array # error # async callbacks': (next) ->
        current = 0
        source = [ {id: 1}, {id: 2}, {id: 3}, {id: 4}, {id: 5}, {id: 6}, {id: 7}, {id: 8}, {id: 9}, {id: 10}, {id: 11} ]
        each(source, 4)
        .on 'data', (n, element, index) ->
            assert.eql current, index
            current++
            if element.id is 6 or element.id is 7
                n( new Error "Testing error in #{element.id}" )
            else setTimeout n, 100
        .on 'error', (err, errors) ->
            assert.eql 8, current
            assert.eql '2 error(s)', err.message
            assert.eql 2, errors.length
            assert.eql 'Testing error in 6', errors[0].message
            assert.eql 'Testing error in 7', errors[1].message
            next()
    'Concurrent # array # one element # async callbacks': (next) ->
        current = 0
        source = [ {id: 1} ]
        each(source, 4)
        .on 'data', (n, element, index) ->
            assert.eql current, index
            current++
            assert.eql current, element.id
            setTimeout n, 100
        .on 'end', ->
            assert.eql current, 1
            setTimeout next, 100
    'Concurrent # array sync callback': (next) ->
        current = 0
        source = [ {id: 1}, {id: 2}, {id: 3}, {id: 4}, {id: 5}, {id: 6}, {id: 7}, {id: 8}, {id: 9} ]
        each(source, 4)
        .on 'data', (n, element, index) ->
            assert.eql current, index
            current++
            assert.eql current, element.id
            n()
        .on 'end', ->
            assert.eql current, 9
            next()
    'Concurrent # object async callbacks': (next) ->
        current = 0
        source = id_1: 1, id_2: 2, id_3: 3, id_4: 4, id_5: 5, id_6: 6, id_7: 7, id_8: 8, id_9: 9
        each(source, 4)
        .on 'data', (n, key, value) ->
            current++
            assert.eql "id_#{current}", key
            assert.eql current, value
            setTimeout n, 100
        .on 'end', ->
            assert.eql current, 9
            setTimeout next, 100
    'Concurrent # object sync callbacks': (next) ->
        current = 0
        source = id_1: 1, id_2: 2, id_3: 3, id_4: 4, id_5: 5, id_6: 6, id_7: 7, id_8: 8, id_9: 9
        each(source, 4)
        .on 'data', (n, key, value) ->
            current++
            assert.eql "id_#{current}", key
            assert.eql current, value
            n()
        .on 'end', ->
            assert.eql current, 9
            next()
