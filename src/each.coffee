
events = require 'events'
stream = require 'stream'
path = require 'path'
glob = require 'glob'
util = require 'util'

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
Each = (@options, @_elements) ->
  # Arguments
  if arguments.length is 1
    @_elements = @options
    @options = {}
  # Internal state
  type = typeof @_elements
  if @_elements is null or type is 'undefined'
    @_elements = []
  else if type is 'number' or type is 'string' or type is 'function' or type is 'boolean'
    @_elements = [@_elements]
  else unless Array.isArray @_elements
    isObject = true
  @_keys = Object.keys @_elements if isObject
  @_errors = []
  @_parallel = 1
  @_sync = false
  @_times = 1
  @_repeat = false
  @_endable = 1
  @_close = false
  # Transformable stream
  # options.objectMode = true
  # stream.Transform.call @, options
  events.EventEmitter.call @, @options
  # Public state
  @total = if @_keys then @_keys.length else @_elements.length
  @setMaxListeners 100
  @started = 0
  @done = 0
  @paused = 0
  @readable = true
  self = @
  process.nextTick => @_run()
  @

# util.inherits Each, stream.Transform
util.inherits Each, events.EventEmitter

Each.prototype._run = () ->
  return if @paused
  # This is the end
  error = null
  if @_endable is 1 and (@_close or @done is @total * @_times or (@_errors.length and @started is @done) )
    # Give a chance for end to be called multiple times
    @readable = false
    if @_errors.length
      if @_parallel isnt 1
        if @_errors.length is 1
          error = @_errors[0]
          error.errors = []
        else 
          error = new Error("Multiple errors (#{@_errors.length})")
          error.errors = @_errors
      else
        error = @_errors[0]
        error.errors = []
      @emit 'error', error if @listeners('error').length or not @listeners('both').length
    else
      args = []
      @emit 'end'
    @emit 'both', error, @done
    # Not testable but re-throw error if not error or both listeners
    # throw error if error and not @listeners('error').length and not @listeners('both').length
    return
  return if @_errors.length isnt 0
  while (if @_parallel is true then (@total * @_times - @started) > 0 else Math.min( (@_parallel - @started + @done), (@total * @_times - @started) ) )
    # Stop on synchronously sent error
    break if @_errors.length isnt 0
    break if @_close
    # Time to call our iterator
    if @_repeat
      index = @started % @_elements.length
    else
      index = Math.floor(@started / @_times)
    @started++
    try
      self = @
      for emit in @listeners 'item'
        l = emit.length
        l++ if @_sync
        switch l
          when 1
            args = []
          when 2
            if @_keys
            then args = [@_elements[@_keys[index]]]
            else args = [@_elements[index]]
          when 3
            if @_keys
            then args = [@_keys[index], @_elements[@_keys[index]]]
            else args = [@_elements[index], index]
          when 4
            if @_keys
            then args = [@_keys[index], @_elements[@_keys[index]], index]
            else return self._next new Error 'Invalid arguments in item callback'
          else
            return self._next new Error 'Invalid arguments in item callback'
        unless @_sync
          args.push ( ->
            count = 0
            (err) ->
              return self._next err if err
              unless ++count is 1
                err = new Error 'Multiple call detected'
                return if self.readable then self._next err else throw err
              self._next()
          )()
        err = emit args...
        self._next err if @_sync
    catch err
      # prevent next to be called if an error occurend inside the
      # error, end or both callbacks
      if self.readable then self._next err else throw err
  null

Each.prototype._next = (err) ->
  @_errors.push err if err? and err instanceof Error
  @done++
  @_run()
Each::end = ->
  console.log 'Function `end` deprecated, use `close` instead.'
  @close()
Each::close = ->
  @_close = true
  @_next()
  @
Each::sync = (s) ->
  @_sync = s
  @
Each::repeat = (t) ->
  @_repeat = true
  @_times = t
  @write null if @_elements.length is 0
  @
Each::times = (t) ->
  @_times = t
  @write null if @_elements.length is 0
  @
Each::files = (base, pattern) ->
  if arguments.length is 1
    pattern = base
    base = null
  if Array.isArray pattern
    for p in pattern then @files p
    return @
  @_endable--
  pattern = path.resolve base, pattern if base
  glob pattern, (err, files) =>
    for file in files
      @_elements.push file
    @total += files.length
    process.nextTick =>
      @_endable++
      @_run()
  @
Each::write = Each::push = (item) ->
  l = arguments.length
  if l is 1
    @_elements.push arguments[0]
  else if l is 2
    @_keys = [] if not @_keys
    @_keys.push arguments[0]
    @_elements[arguments[0]] = arguments[1]
  @total++
  # @started - @done < @_parallel
  @
Each::unshift = (item) ->
  l = arguments.length
  if @_repeat
    index = @started % @_elements.length
  else
    index = Math.floor(@started / @_times)
  if l is 1
    # @_elements.unshift arguments[0]
    @_elements.splice index, 0, arguments[0]
  else if l is 2
    @_keys = [] if not @_keys
    # @_keys.unshift arguments[0]
    @_keys.splice index, 0, arguments[0]
    @_elements[arguments[0]] = arguments[1]
  @total++
  @
Each::pause = ->
  @paused++
Each::resume = ->
  @paused--
  @_run()
Each::parallel = (mode) ->
  # Concurrent
  if typeof mode is 'number' then @_parallel = mode
  # Parallel
  else if mode then @_parallel = mode
  # Sequential (in case parallel is called multiple times)
  else @_parallel = 1
  @

module.exports = (elements) ->
  new Each elements
module.exports.Each = Each
