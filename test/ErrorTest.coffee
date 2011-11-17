
assert = require 'assert'
each = require '../index'

module.exports = 
    'Error # Concurrent # error and end callbacks': (next) ->
        current = 0
        error_called = false
        error_assert = (err, errors) ->
            assert.eql 8, current
            assert.eql '2 error(s)', err.message
            assert.eql 2, errors.length
            assert.eql 'Testing error in 6', errors[0].message
            assert.eql 'Testing error in 7', errors[1].message
        each( [ {id: 1}, {id: 2}, {id: 3}, {id: 4}, {id: 5}, {id: 6}, {id: 7}, {id: 8}, {id: 9}, {id: 10}, {id: 11} ] )
        .parallel( 4 )
        .on 'item', (n, element, index) ->
            assert.eql current, index
            current++
            if element.id is 6 or element.id is 7
                n( new Error "Testing error in #{element.id}" )
            else setTimeout n, 100
        .on 'error', (err, errors) ->
            error_assert.call null, err, errors
            error_called = true
        .on 'end', (err, errors) ->
            assert.ok error_called
            error_assert.call null, err, errors
            next()
    'Error # Parallel # error callback': (next) ->
        current = 0
        each( [{id: 1}, {id: 2}, {id: 3}, {id: 4}] )
        .parallel( true )
        .on 'item', (n, element, index) ->
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
    'Error # Parallel # end callback': (next) ->
        current = 0
        each( [{id: 1}, {id: 2}, {id: 3}, {id: 4}] )
        .parallel( true )
        .on 'item', (n, element, index) ->
            assert.eql current, index
            current++
            if element.id is 1 or element.id is 3
                n( new Error "Testing error in #{element.id}" )
            else setTimeout n, 100
        .on 'end', (err, errs) ->
            assert.eql '2 error(s)', err.message
            assert.eql 2, errs.length
            assert.eql 'Testing error in 1', errs[0].message
            assert.eql 'Testing error in 3', errs[1].message
            return next()
    'Error # Sequential # error callback': (next) ->
        current = 0
        each( [ {id: 1}, {id: 2}, {id: 3} ] )
        .on 'item', (n, element, index) ->
            assert.eql current, index
            current++
            if element.id is 2
                n( new Error 'Testing error' )
            else setTimeout n, 100
        .on 'error', (err) ->
            assert.eql 'Testing error', err.message
            next()
    