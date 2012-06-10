
Stream = require 'stream'

###
each(elements)
.mode(parallel=false|true|integer)
.on('item', callback)
.on('error', callback)
.on('end', callback)
.on('both', callback)
Chained and parallel async iterator in one elegant function
###
module.exports = (elements) ->
    type = typeof elements
    if elements is null or type is 'undefined' or type is 'number' or type is 'string' or type is 'function' or type is 'boolean'
        elements = [elements]
    else unless Array.isArray elements
        isObject = true
    keys = Object.keys elements if isObject
    started = 0
    done = 0
    errors = []
    total = if keys then keys.length else elements.length
    parallel = 1
    eacher = new Stream
    eacher.paused = 0
    eacher.readable = true
    eacher.pause = ->
        eacher.paused++
    eacher.resume = ->
        eacher.paused--
        run()
    # eacher.destroy = ->
        # nothing
    eacher.parallel = (mode) ->
        # Concurrent
        if typeof mode is 'number' then parallel = mode
        # Parallel
        else if mode then parallel = total
        # Sequential (in case parallel is called multiple times)
        else parallel = 1
        eacher
    run = () ->
        return if eacher.paused
        # This is the end
        if done is total or (errors.length and started is done)
            eacher.readable = false
            if errors.length
                if parallel isnt 1
                    if errors.length is 1
                    then args = [errors[0], errors]
                    else args = [new Error("Multiple errors (#{errors.length})"), errors]
                else
                    args = [errors[0]]
                # emit error only if
                # - there is an error callback
                # - there is no error callback and no both callback
                lerror = eacher.listeners('error').length
                lboth = eacher.listeners('both').length
                emitError = lerror or (not lerror and not lboth)
                eacher.emit 'error', args... if emitError
            else
                args = []
                eacher.emit 'end'
            return eacher.emit 'both', args...
        return if errors.length isnt 0
        while Math.min( (parallel - started + done), (total - started) )
            # Stop on synchronously sent error
            break if errors.length isnt 0
            # Time to call our iterator
            if keys
            then args = [next, keys[started], elements[keys[started]]]
            else args = [next, elements[started], started]
            started++
            try
                eacher.emit 'item', args...
            catch e
                # prevent next to be called if an error occurend inside the
                # error, end or both callbacks
                next e if eacher.readable
        # call()
    next = (err) ->
        errors.push err if err? and err instanceof Error
        done++
        run()
    process.nextTick run
    eacher
