
assert = require 'assert'
each = require '../index'

module.exports = 
    'Parallel # array': (next) ->
        current = 0
        end_called = false
        each( [{id: 1}, {id: 2}, {id: 3}])
        .parallel( true )
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
    'Parallel # object': (next) ->
        current = 0
        each( {id_1: 1, id_2: 2, id_3: 3} )
        .parallel( true )
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
    'Parallel # undefined': (next) ->
        current = 0
        each( undefined )
        .parallel( true )
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
    'Parallel # null': (next) ->
        current = 0
        each( null )
        .parallel( true )
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
    'Parallel # string': (next) ->
        current = 0
        each( 'id_1' )
        .parallel( true )
        .on 'item', (next, element, index) ->
            assert.eql current, index
            current++
            assert.eql "id_1", element
            setTimeout next, 100
        .on 'error', (err) ->
            assert.ifError err
        .on 'end', ->
            assert.eql current, 1
            next()
    'Parallel # number': (next) ->
        current = 0
        each( 3.14 )
        .parallel( true )
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
    'Parallel # boolean': (next) ->
        # Current tick
        current = 0
        each( false )
        .parallel( true )
        .on 'item', (next, element, index) ->
            assert.eql index, 0
            current++
            assert.eql false, element
            next()
        .on 'error', (err) ->
            assert.ifError err
        .on 'end', ->
            assert.eql current, 1
            # New tick
            current = 0
            each( true )
            .parallel( true )
            .on 'item', (next, element, index) ->
                assert.eql index, 0
                current++
                assert.eql true, element
                setTimeout next, 100
            .on 'error', (err) ->
                assert.ifError err
            .on 'end', ->
                assert.eql current, 1
                next()
    'Parallel # function': (next) ->
        current = 0
        source = (c) -> c()
        each( source )
        .parallel( true )
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
        
