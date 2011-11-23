
assert = require 'assert'
each = require '../index'

module.exports = 
    'Concurrent # array # multiple elements # async callbacks': (next) ->
        current = 0
        end_called = false
        each( [ {id: 1}, {id: 2}, {id: 3}, {id: 4}, {id: 5}, {id: 6}, {id: 7}, {id: 8}, {id: 9} ] )
        .parallel( 4 )
        .on 'item', (n, element, index) ->
            assert.eql current, index
            current++
            assert.eql current, element.id
            setTimeout n, 100
        .on 'end', ->
            assert.eql current, 9
            end_called = true
        .on 'both', (err) ->
            assert.ifError err
            assert.ok end_called
            next()
    'Concurrent # array # one element # async callbacks': (next) ->
        current = 0
        each( [ {id: 1} ] )
        .parallel( 4 )
        .on 'item', (n, element, index) ->
            assert.eql current, index
            current++
            assert.eql current, element.id
            setTimeout n, 100
        .on 'error', (err) ->
            assert.ifError err
        .on 'end', ->
            assert.eql current, 1
            setTimeout next, 100
    'Concurrent # array # empty': (next) ->
        current = 0
        each( [] )
        .parallel( 4 )
        .on 'item', (n, element, index) ->
            current++
            n()
        .on 'error', (err) ->
            assert.ifError err
        .on 'both', ->
            assert.eql current, 0
            next()
    'Concurrent # array sync callback': (next) ->
        current = 0
        each( [ {id: 1}, {id: 2}, {id: 3}, {id: 4}, {id: 5}, {id: 6}, {id: 7}, {id: 8}, {id: 9} ] )
        .parallel( 4 )
        .on 'item', (n, element, index) ->
            assert.eql current, index
            current++
            assert.eql current, element.id
            n()
        .on 'error', (err) ->
            assert.ifError err
        .on 'end', ->
            assert.eql current, 9
            next()
    'Concurrent # object async callbacks': (next) ->
        current = 0
        each( id_1: 1, id_2: 2, id_3: 3, id_4: 4, id_5: 5, id_6: 6, id_7: 7, id_8: 8, id_9: 9 )
        .parallel( 4 )
        .on 'item', (n, key, value) ->
            current++
            assert.eql "id_#{current}", key
            assert.eql current, value
            setTimeout n, 100
        .on 'error', (err) ->
            assert.ifError err
        .on 'end', ->
            assert.eql current, 9
            setTimeout next, 100
    'Concurrent # object sync callbacks': (next) ->
        current = 0
        each( id_1: 1, id_2: 2, id_3: 3, id_4: 4, id_5: 5, id_6: 6, id_7: 7, id_8: 8, id_9: 9 )
        .parallel( 4 )
        .on 'item', (n, key, value) ->
            current++
            assert.eql "id_#{current}", key
            assert.eql current, value
            n()
        .on 'error', (err) ->
            assert.ifError err
        .on 'end', ->
            assert.eql current, 9
            next()
    'Concurrent # function': (next) ->
        current = 0
        each( (c) -> c() )
        .parallel( 4 )
        .on 'item', (n, element, index) ->
            assert.eql current, index
            current++
            assert.eql typeof element, 'function'
            element n
        .on 'error', (err) ->
            assert.ifError err
        .on 'end', ->
            assert.eql current, 1
            next()
