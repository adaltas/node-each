
EventEmitter = require('events').EventEmitter

###
each(elements)
.mode(parallel=false|true|integer)
.on('item', callback)
.on('error', callback)
.on('success', callback)
.on('end', callback)
Chained and parallel async iterator in one elegant function
###
module.exports = (elements) ->
    type = typeof elements
    if elements is null or type is 'undefined' or type is 'number' or type is 'string' or type is 'function'
        elements = [elements]
    else unless Array.isArray elements
        isObject = true
    keys = Object.keys elements if isObject
    started = 0
    done = 0
    pause = 0
    errors = []
    total = if keys then keys.length else elements.length
    parallel = 1
    eacher = new EventEmitter
    eacher.parallel = (mode) ->
        # Concurrent
        if typeof mode is 'number' then parallel = mode
        # Parallel
        else if mode then parallel = total
        # Sequential (in case parallel is called multiple times)
        else parallel = 1
        eacher
    eacher.pause = () ->
        pause++
    eacher.resume = () ->
        pause--
        run()
    call = () ->
        if keys
        then args = [next, keys[started], elements[keys[started]]]
        else args = [next, elements[started], started]
        started++
        process.nextTick () ->
            try
                    eacher.emit 'item', args...
            catch e
                next e
    run = () ->
        return if pause
        # This is the end
        if done is total or (errors.length and started is done)
            if parallel isnt 1 and errors.length
                args = [new Error("#{errors.length} error(s)"), errors]
                eacher.emit 'error', args... if eacher.listeners('error').length
            else if errors.length
                args = [errors[0]]
                eacher.emit 'error', args... if eacher.listeners('error').length
            else
                args = []
                eacher.emit 'success'
            return eacher.emit 'end', args...
        call() for key in [0 ... Math.min( (parallel - started + done), (total - started) )] unless errors.length
    next = (err) ->
        errors.push err if err? and err instanceof Error
        done++
        run()
    process.nextTick ->
        run() for key in [0 ... Math.min(parallel, total)]
    eacher
