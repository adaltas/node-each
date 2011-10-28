
###
each(elements, parallel=false, callback)
Chained and parallel async iterator in one elegant function
###
module.exports = (elements, parallel, callback, end_callback) ->
    if arguments.length is 2
        callback = parallel
        parallel = false
    else if arguments.length is 3 and typeof parallel is 'function'
        end_callback = callback
        callback = parallel
        parallel = false
    type = typeof elements
    if elements is null or type is 'undefined' or type is 'number' or type is 'string'
        elements = [elements]
    else unless Array.isArray elements
        isObject = true
    i = 0
    keys = Object.keys elements if isObject
    l = if keys then keys.length else elements.length
    # Concurrent
    if typeof parallel is 'number'
    # Parallel
    else if parallel then parallel = l
    # Sequential
    else parallel = 1
    parallel = Math.min(parallel, if keys then keys.length else elements.length)
    next = () ->
        i++
        return (end_callback ? callback) null, null if i is l
        return if parallel + i > l 
        if keys
        then args = [keys[parallel + i - 1], elements[keys[parallel + i - 1]], -> process.nextTick next]
        else args = [elements[parallel + i - 1], -> process.nextTick next]
        callback.apply null, args
    for key in [0 ... parallel]
        if keys
        then args = [keys[key], elements[keys[key]], -> process.nextTick next]
        else args = [elements[key], -> process.nextTick next]
        callback.apply null, args
