
EventEmitter = require('events').EventEmitter

class Eacher extends EventEmitter
    


###
each(elements, parallel=false, callback)
Chained and parallel async iterator in one elegant function
###
module.exports = (elements, parallel) ->
    eacher = new EventEmitter
    type = typeof elements
    if elements is null or type is 'undefined' or type is 'number' or type is 'string' or type is 'function'
        elements = [elements]
    else unless Array.isArray elements
        isObject = true
    keys = Object.keys elements if isObject
    started = 0
    done = 0
    total = if keys then keys.length else elements.length
    # Concurrent
    if typeof parallel is 'number'
    # Parallel
    else if parallel then parallel = total
    # Sequential
    else parallel = 1
    parallel = Math.min(parallel, if keys then keys.length else elements.length)
    errors = []
    run = (i) ->
        if keys
        then args = [next, keys[i], elements[keys[i]]]
        else args = [next, elements[i], started]
        started++
        try
            process.nextTick () ->
                eacher.emit 'data', args...
        catch e
            next e
    next = (err) ->
        errors.push err if err? and err instanceof Error
        done++
        # This is the end
        if done is total or (errors.length and started is done)
            if parallel isnt 1 and errors.length
                err = new Error "#{errors.length} error(s)"
                return eacher.emit 'error', err, errors
            else if errors.length
                return eacher.emit 'error', errors[0]
            else
                args = if keys then [null, null, err] else [null, err]
                return eacher.emit 'end', null, args...
        # No more parallel iteration
        return if parallel + done > total
        # Run next iteration
        run parallel + done - 1 unless errors.length
    for key in [0 ... parallel]
        run key
    eacher
