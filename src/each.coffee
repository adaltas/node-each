
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
  errors = []
  parallel = 1
  events = 
    item: []
    error: []
    end: []
    both: []
  times = []
  eacher = {}
  eacher.total = if keys then keys.length else elements.length
  eacher.started = 0
  eacher.done = 0
  times = 1
  eacher.paused = 0
  eacher.readable = true
  eacher.pause = ->
    eacher.paused++
  eacher.resume = ->
    eacher.paused--
    run()
  eacher.parallel = (mode) ->
    # Concurrent
    if typeof mode is 'number' then parallel = mode
    # Parallel
    # else if mode then parallel = eacher.total
    else if mode then parallel = mode
    # Sequential (in case parallel is called multiple times)
    else parallel = 1
    eacher
  eacher.times = (t) ->
    times = t
    eacher
  eacher.on = (ev, callback) ->
    events[ev].push callback
    eacher
  run = () ->
    return if eacher.paused
    # This is the end
    if eacher.done is eacher.total * times or (errors.length and eacher.started is eacher.done)
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
        lerror = events.error.length
        lboth = events.both.length
        emitError = lerror or (not lerror and not lboth)
        for emit in events.error then emit args... if emitError
      else
        args = []
        # eacher.emit 'end'
        for emit in events.end then emit()
      # return eacher.emit 'both', args...
      for emit in events.both then emit args...
      return
    return if errors.length isnt 0
    while (if parallel is true then (eacher.total * times - eacher.started) > 0 else Math.min( (parallel - eacher.started + eacher.done), (eacher.total * times - eacher.started) ) )
      # Stop on synchronously sent error
      break if errors.length isnt 0
      # Time to call our iterator
      index = Math.floor(eacher.started / times)
      # if keys
      # then args = [keys[index], elements[keys[index]], next]
      # else args = [elements[index], index, next]
      eacher.started++
      try
        # eacher.emit 'item', args...
        for emit in events.item
          switch emit.length
            when 1
              args = [next]
            when 2
              if keys
              then args = [elements[keys[index]], next]
              else args = [elements[index], next]
            when 3
              if keys
              then args = [keys[index], elements[keys[index]], next]
              else args = [elements[index], index, next]
            when 4
              if keys
              then args = [keys[index], elements[keys[index]], index, next]
              else return next new Error 'Invalid arguments in item callback'
            else
              return next new Error 'Invalid arguments in item callback'
          emit args...
      catch e
        # prevent next to be called if an error occurend inside the
        # error, end or both callbacks
        next e if eacher.readable
    null
  next = (err) ->
    errors.push err if err? and err instanceof Error
    eacher.done++
    run()
  process.nextTick run
  eacher
