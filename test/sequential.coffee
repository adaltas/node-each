
should = require 'should'
each = require '../index'

describe 'Sequential', ->
    it 'array', (next) ->
        current = 0
        end_called = false
        each( [ {id: 1}, {id: 2}, {id: 3} ] )
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
    it 'object', (next) ->
        current = 0
        each( {id_1: 1, id_2: 2, id_3: 3} )
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
    it 'undefined', (next) ->
        current = 0
        each( undefined )
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
    it 'null', (next) ->
        current = 0
        each( null )
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
    it 'string', (next) ->
        current = 0
        each( 'id_1' )
        .on 'item', (nnext, element, index) ->
            index.should.eql current
            current++
            element.should.eql "id_1"
            setTimeout next, 100
        .on 'error', (err) ->
            should.not.exist err
        .on 'end', ->
            current.should.eql 1
            next()
    it 'number', (next) ->
        current = 0
        each( 3.14 )
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
    it 'function', (next) ->
        current = 0
        source = (c) -> c()
        each(source)
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

