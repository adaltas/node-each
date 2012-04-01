
should = require 'should'
each = require '../index'

describe 'Parallel', ->
    it 'Parallel # array', (next) ->
        current = 0
        end_called = false
        each( [{id: 1}, {id: 2}, {id: 3}] )
        .parallel( true )
        .on 'item', (next, element, index) ->
            index.should.eql current
            current++
            element.id.should.eql current
            setTimeout next, 100
        .on 'end', ->
            current.should.eql 3
            end_called = true
        .on 'both', (err) ->
            should.not.exist err
            end_called.should.be.ok
            next()
    it 'Parallel # object', (next) ->
        current = 0
        each( {id_1: 1, id_2: 2, id_3: 3} )
        .parallel( true )
        .on 'item', (next, key, value) ->
            current++
            key.should.eql "id_#{current}"
            value.should.eql current
            setTimeout next, 100
        .on 'error', (err) ->
            should.not.exist err
        .on 'end', ->
            current.should.eql 3
            next()
    it 'Parallel # undefined', (next) ->
        current = 0
        each( undefined )
        .parallel( true )
        .on 'item', (next, element, index) ->
            index.should.eql current
            current++
            should.not.exist element
            setTimeout next, 100
        .on 'error', (err) ->
            should.not.exist err
        .on 'end', ->
            current.should.eql 1
            next()
    it 'Parallel # null', (next) ->
        current = 0
        each( null )
        .parallel( true )
        .on 'item', (next, element, index) ->
            index.should.eql current
            current++
            should.not.exist element
            setTimeout next, 100
        .on 'error', (err) ->
            should.not.exist err
        .on 'end', ->
            current.should.eql 1
            next()
    it 'Parallel # string', (next) ->
        current = 0
        each( 'id_1' )
        .parallel( true )
        .on 'item', (next, element, index) ->
            index.should.eql current
            current++
            element.should.eql "id_1"
            setTimeout next, 100
        .on 'error', (err) ->
            should.not.exist err
        .on 'end', ->
            current.should.eql 1
            next()
    it 'Parallel # number', (next) ->
        current = 0
        each( 3.14 )
        .parallel( true )
        .on 'item', (next, element, index) ->
            index.should.eql current
            current++
            element.should.eql 3.14
            setTimeout next, 100
        .on 'error', (err) ->
            should.not.exist err
        .on 'end', ->
            current.should.eql 1
            next()
    it 'Parallel # boolean', (next) ->
        # Current tick
        current = 0
        each( false )
        .parallel( true )
        .on 'item', (next, element, index) ->
            index.should.eql 0
            current++
            element.should.not.be.ok
            next()
        .on 'error', (err) ->
            should.not.exist err
        .on 'end', ->
            current.should.eql 1
            # New tick
            current = 0
            each( true )
            .parallel( true )
            .on 'item', (next, element, index) ->
                index.should.eql 0
                current++
                element.should.be.ok
                setTimeout next, 100
            .on 'error', (err) ->
                should.not.exist err
            .on 'end', ->
                current.should.eql 1
                next()
    it 'Parallel # function', (next) ->
        current = 0
        source = (c) -> c()
        each( source )
        .parallel( true )
        .on 'item', (next, element, index) ->
            index.should.eql current
            current++
            element.should.be.a 'function'
            element next
        .on 'error', (err) ->
            should.not.exist err
        .on 'end', ->
            current.should.eql 1
            next()
        
