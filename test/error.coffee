
should = require 'should'
each = require '../index'

describe 'Error', ->
    it 'Concurrent # error and both callbacks', (next) ->
        current = 0
        error_called = false
        error_assert = (err, errs) ->
            current.should.eql 9
            err.message.should.eql 'Multiple errors (2)'
            errs.length.should.eql 2
            errs[0].message.should.eql 'Testing error in 6'
            errs[1].message.should.eql 'Testing error in 7'
        each( [ {id: 1}, {id: 2}, {id: 3}, {id: 4}, {id: 5}, {id: 6}, {id: 7}, {id: 8}, {id: 9}, {id: 10}, {id: 11} ] )
        .parallel( 4 )
        .on 'item', (n, element, index) ->
            index.should.eql current
            current++
            setTimeout ->
                if element.id is 6 or element.id is 7
                    n new Error "Testing error in #{element.id}"
                else 
                    n()
            , 100
        .on 'error', (err, errs) ->
            error_assert.call null, err, errs
            error_called = true
        .on 'end', (err, errs) ->
            assert.ok false
        .on 'both', (err, errs) ->
            error_called.should.be.ok 
            error_assert.call null, err, errs
            next()
    it 'Parallel # multiple errors # error callback', (next) ->
        # when multiple errors are thrown, a new error object is created
        # with a message indicating the number of errors. The original 
        # errors are available as an array in the second argument of the
        # `error` event.
        current = 0
        each( [{id: 1}, {id: 2}, {id: 3}, {id: 4}] )
        .parallel( true )
        .on 'item', (n, element, index) ->
            index.should.eql current
            current++
            setTimeout ->
                if element.id is 1 or element.id is 3
                    n( new Error "Testing error in #{element.id}" )
                else
                    n()
            , 100
        .on 'error', (err, errs) ->
            err.message.should.eql 'Multiple errors (2)'
            errs.length.should.eql 2
            errs[0].message.should.eql 'Testing error in 1'
            errs[1].message.should.eql 'Testing error in 3'
            return next()
        .on 'end', (err, errs) ->
            false.should.be.ok 
    it 'Parallel # single error # error callback', (next) ->
        # when on one error is thrown, the error is passed to
        # the `error` event as is as well as a single element array 
        # of the second argument.
        current = 0
        each( [{id: 1}, {id: 2}, {id: 3}, {id: 4}] )
        .parallel( true )
        .on 'item', (n, element, index) ->
            index.should.eql current
            current++
            setTimeout ->
                if element.id is 3
                    n( new Error "Testing error in #{element.id}" )
                else
                    n()
            , 100
        .on 'error', (err, errs) ->
            err.message.should.eql 'Testing error in 3'
            errs.length.should.eql 1
            errs[0].message.should.eql 'Testing error in 3'
            return next()
        .on 'end', (err, errs) ->
            false.should.be.ok 
    it 'Parallel # async # both callback', (next) ->
        current = 0
        each( [{id: 1}, {id: 2}, {id: 3}, {id: 4}] )
        .parallel( true )
        .on 'item', (n, element, index) ->
            index.should.eql current
            current++
            setTimeout ->
                if element.id is 1 or element.id is 3
                    n( new Error "Testing error in #{element.id}" )
                else
                    n()
            , 100
        .on 'both', (err, errs) ->
            err.message.should.eql 'Multiple errors (2)'
            errs.length.should.eql 2
            errs[0].message.should.eql 'Testing error in 1', 
            errs[1].message.should.eql 'Testing error in 3'
            return next()
        .on 'end', (err, errs) ->
            false.should.be.ok 
    it 'Parallel # sync # both callback', (next) ->
        current = 0
        each( [{id: 1}, {id: 2}, {id: 3}, {id: 4}] )
        .parallel( true )
        .on 'item', (n, element, index) ->
            index.should.eql current
            current++
            if element.id is 1 or element.id is 3
                n( new Error "Testing error in #{element.id}" )
            else setTimeout n, 100
        .on 'both', (err, errs) ->
            err.message.should.eql 'Multiple errors (2)'
            errs.length.should.eql 2
            errs[0].message.should.eql 'Testing error in 1'
            errs[1].message.should.eql 'Testing error in 3'
            return next()
    it 'Sequential # error callback', (next) ->
        current = 0
        each( [ {id: 1}, {id: 2}, {id: 3} ] )
        .on 'item', (n, element, index) ->
            index.should.eql current
            current++
            if element.id is 2
                n( new Error 'Testing error' )
            else setTimeout n, 100
        .on 'error', (err) ->
            err.message.should.eql 'Testing error'
            next()
        .on 'end', (err, errs) ->
            false.should.be.ok 
    