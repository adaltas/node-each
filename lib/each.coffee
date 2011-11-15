
EventEmitter = require('events').EventEmitter

class Eacher extends EventEmitter
    


###
each(elements)
.mode(parallel=false|true|integer)
.on('data', callback)
.on('error', callback)
.on('success', callback)
.on('end', callback)
Chained and parallel async iterator in one elegant function
###
module.exports = (elements) ->
    eacher = new EventEmitter
    type = typeof elements
    if elements is null or type is 'undefined' or type is 'number' or type is 'string' or type is 'function'
        elements = [elements]
    else unless Array.isArray elements
        isObject = true
    keys = Object.keys elements if isObject
    started = 0
    done = 0
    errors = []
    total = if keys then keys.length else elements.length
    parallel = 1
    eacher.parallel = (mode) ->
        # Concurrent
        if typeof mode is 'number' then parallel = Math.min(mode, total)
        # Parallel
        else if mode then parallel = total
        # Sequential (in case parallel is called multiple times)
        else parallel = 1
        eacher
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
                args = [new Error("#{errors.length} error(s)"), errors]
                eacher.emit 'error', args...
            else if errors.length
                args = [errors[0]]
                eacher.emit 'error', args...
            else
                args = []
                eacher.emit 'success'
            return eacher.emit 'end', args...
        # No more parallel iteration
        return if parallel + done > total
        # Run next iteration
        run parallel + done - 1 unless errors.length
    process.nextTick ->
        for key in [0 ... parallel]
            run key
    eacher
