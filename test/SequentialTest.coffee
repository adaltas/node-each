
assert = require 'assert'
each = require '../index'

module.exports = 
    'Sequential # array': (next) ->
        current = 0
        end_called = false
        each( [ {id: 1}, {id: 2}, {id: 3} ] )
        .on 'item', (next, element, index) ->
            assert.eql current, index
            current++
            assert.eql current, element.id
            setTimeout next, 100
        .on 'end', ->
            assert.eql current, 3
            end_called = true
        .on 'both', (err) ->
            assert.ifError err
            assert.ok end_called
            next()
    'Sequential # object': (next) ->
        current = 0
        each( {id_1: 1, id_2: 2, id_3: 3} )
        .on 'item', (next, key, value) ->
            current++
            assert.eql "id_#{current}", key
            assert.eql current, value
            setTimeout next, 100
        .on 'error', (err) ->
            assert.ifError err
        .on 'end', ->
            assert.eql current, 3
            next()
    'Sequential # undefined': (next) ->
        current = 0
        each( undefined )
        .on 'item', (next, element, index) ->
            assert.eql current, index
            current++
            assert.eql undefined, element
            setTimeout next, 100
        .on 'error', (err) ->
            assert.ifError err
        .on 'end', ->
            assert.eql current, 1
            next()
    'Sequential # null': (next) ->
        current = 0
        each( null )
        .on 'item', (next, element, index) ->
            assert.eql current, index
            current++
            assert.eql null, element
            setTimeout next, 100
        .on 'error', (err) ->
            assert.ifError err
        .on 'end', ->
            assert.eql current, 1
            next()
    'Sequential # string': (next) ->
        current = 0
        each( 'id_1' )
        .on 'item', (nnext, element, index) ->
            assert.eql current, index
            current++
            assert.eql "id_1", element
            setTimeout next, 100
        .on 'error', (err) ->
            assert.ifError err
        .on 'end', ->
            assert.eql current, 1
            next()
    'Sequential # number': (next) ->
        current = 0
        each( 3.14 )
        .on 'item', (next, element, index) ->
            assert.eql current, index
            current++
            assert.eql 3.14, element
            setTimeout next, 100
        .on 'error', (err) ->
            assert.ifError err
        .on 'end', ->
            assert.eql current, 1
            next()
    'Sequential # function': (next) ->
        current = 0
        source = (c) -> c()
        each(source)
        .on 'item', (next, element, index) ->
            assert.eql current, index
            current++
            assert.eql typeof element, 'function'
            element next
        .on 'error', (err) ->
            assert.ifError err
        .on 'end', ->
            assert.eql current, 1
            next()

