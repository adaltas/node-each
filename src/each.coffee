
path = require 'path'
glob = require 'glob'

###
each(elements)
.parallel(false|true|integer)
.sync(false)
.times(1)
.repeat(1)
.files(cwd, ['./*.coffee'])
.write(element)
.pause()
.resume()
.on('item', callback)
.on('error', callback)
.on('end', callback)
.on('both', callback)
Chained and parallel async iterator in one elegant function
###
module.exports = (elements) ->
  type = typeof elements
  if elements is null or type is 'undefined'
    elements = []
  else if type is 'number' or type is 'string' or type is 'function' or type is 'boolean'
    elements = [elements]
  else unless Array.isArray elements
    isObject = true
  arglength = arguments.length
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
  sync = false
  times = 1
  repeat = false
  endable = 1
  eacher.paused = 0
  eacher.readable = true
  end = false
  eacher.write = eacher.push = (item) ->
    l = arguments.length
    if l is 1
      elements.push arguments[0]
    else if l is 2
      keys = [] if not keys
      keys.push arguments[0]
      elements[arguments[0]] = arguments[1]
    eacher.total++
    eacher
  eacher.unshift = (item) ->
    l = arguments.length
    if repeat
      index = eacher.started % elements.length
    else
      index = Math.floor(eacher.started / times)
    # console.log index
    if l is 1
      # elements.unshift arguments[0]
      elements.splice index, 0, arguments[0]
    else if l is 2
      keys = [] if not keys
      # keys.unshift arguments[0]
      keys.splice index, 0, arguments[0]
      elements[arguments[0]] = arguments[1]
    eacher.total++
    eacher
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
  eacher.on = (ev, callback) ->
    events[ev].push callback
    eacher
  eacher.end = ->
    end = true
    next()
    eacher
  eacher.sync = (s) ->
    sync = s
    eacher
  eacher.repeat = (t) ->
    repeat = true
    times = t
    eacher.write null if elements.length is 0
    eacher
  eacher.times = (t) ->
    times = t
    eacher.write null if elements.length is 0
    eacher
  eacher.files = (base, pattern) ->
    if arguments.length is 1
      pattern = base
      base = null
    if Array.isArray pattern
      for p in pattern then @files p
      return @
    endable--
    pattern = path.resolve base, pattern if base
    glob pattern, (err, files) ->
      eacher.total += files.length
      for file in files
        elements.push file
      process.nextTick ->
        endable++
        run()
    eacher
  run = () ->
    return if eacher.paused
    # This is the end
    error = null
    if endable is 1 and (end or eacher.done is eacher.total * times or (errors.length and eacher.started is eacher.done) )
      # Give a chance for end to be called multiple times
      eacher.readable = false
      if errors.length
        if parallel isnt 1
          if errors.length is 1
            error = errors[0]
            error.errors = []
          else 
            error = new Error("Multiple errors (#{errors.length})")
            error.errors = errors
        else
          error = errors[0]
          error.errors = []
        for emit in events.error then emit error if events.error.length
      else
        args = []
        for emit in events.end then emit eacher.done 
      for emit in events.both then emit error, eacher.done
      # Not testable but re-throw error if not error or both listeners
      throw error if error and not events.error.length and not events.both.length
      return
    return if errors.length isnt 0
    while (if parallel is true then (eacher.total * times - eacher.started) > 0 else Math.min( (parallel - eacher.started + eacher.done), (eacher.total * times - eacher.started) ) )
      # Stop on synchronously sent error
      break if errors.length isnt 0
      break if end
      # Time to call our iterator
      if repeat
        index = eacher.started % elements.length
      else
        index = Math.floor(eacher.started / times)
      eacher.started++
      try
        for emit in events.item
          l = emit.length
          l++ if sync
          switch l
            when 1
              args = []
            when 2
              if keys
              then args = [elements[keys[index]]]
              else args = [elements[index]]
            when 3
              if keys
              then args = [keys[index], elements[keys[index]]]
              else args = [elements[index], index]
            when 4
              if keys
              then args = [keys[index], elements[keys[index]], index]
              else return next new Error 'Invalid arguments in item callback'
            else
              return next new Error 'Invalid arguments in item callback'
          unless sync
            args.push ( ->
              count = 0
              (err) ->
                return next err if err
                unless ++count is 1
                  err = new Error 'Multiple call detected'
                  return if eacher.readable then next err else throw err 
                next()
            )()
          err = emit args...
          next err if sync
      catch err
        # prevent next to be called if an error occurend inside the
        # error, end or both callbacks
        if eacher.readable then next err else throw err
    null
  next = (err) ->
    errors.push err if err? and err instanceof Error
    eacher.done++
    run()
  process.nextTick run
  eacher
