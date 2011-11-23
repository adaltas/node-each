
assert = require 'assert'
each = require '../index'

module.exports = 
    'Throttle # next before resume': (next) ->
        eacher = each( [ {id: 1}, {id: 2}, {id: 3}, {id: 4}, {id: 5}, {id: 6}, {id: 7}, {id: 8}, {id: 9} ] )
        .parallel( 4 )
        .on 'item', (n, element, index) ->
            if element.id is 2
                eacher.pause()
                setTimeout ->
                    eacher.resume()
                , 100
            n()
        .on 'both', (err, errors) ->
            assert.ifError err
            next()
    'Throttle # next after resume': (next) ->
        eacher = each( [ {id: 1}, {id: 2}, {id: 3}, {id: 4}, {id: 5}, {id: 6}, {id: 7}, {id: 8}, {id: 9} ] )
        .parallel( 4 )
        .on 'item', (n, element, index) ->
            if element.id is 2
                eacher.pause()
                setTimeout ->
                    eacher.resume()
                    n()
                , 100
            else
                n()
        .on 'both', (err, errors) ->
            assert.ifError err
            next()
    'Throttle # multiple pause # next before resume': (next) ->
        eacher = each( [ {id: 1}, {id: 2}, {id: 3}, {id: 4}, {id: 5}, {id: 6}, {id: 7}, {id: 8}, {id: 9} ] )
        .parallel( 4 )
        .on 'item', (n, element, index) ->
            if element.id % 2 is 0
                eacher.pause()
                setTimeout ->
                    eacher.resume()
                    n()
                , 10 * element.id
            else
                n()
        .on 'both', (err, errors) ->
            assert.ifError err
            next()
    'Throttle # multiple pause # next after resume': (next) ->
        eacher = each( [ {id: 1}, {id: 2}, {id: 3}, {id: 4}, {id: 5}, {id: 6}, {id: 7}, {id: 8}, {id: 9} ] )
        .parallel( 4 )
        .on 'item', (n, element, index) ->
            if element.id % 2 is 0
                eacher.pause()
                setTimeout ->
                    eacher.resume()
                , 10 * element.id
            n()
        .on 'both', (err, errors) ->
            assert.ifError err
            next()
