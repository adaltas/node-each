
###
each(elements, parallel=false, callback)
Chained and parallel async iterator in one elegant function
###
module.exports = (elements, parallel, callback) ->
    unless callback
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
    if parallel
        next = () ->
            i++
            return callback null, null if i is l
        for key in keys ? elements
            if keys
            then args = [key, elements[key], next]
            else args = [key, next]
            callback.apply null, args
    else
        next = () ->
            return callback null, null if i is l
            if keys
            then args = [keys[i], elements[keys[i++]], next]
            else args = [elements[i++], next]
            callback.apply null, args
        process.nextTick next
