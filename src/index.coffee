import {is_object_literal, merge, mutate} from 'mixme'

is_promise = (obj) ->
  !!obj and (typeof obj is 'object' || typeof obj is 'function') and typeof obj.then is 'function'

normalize_options = (options, argument, position) ->
  if is_object_literal(argument)
    mutate options, argument
  else if typeof argument is 'function'
    options.handler = argument
  else if typeof argument is 'boolean'
    mutate options, concurrency: if typeof argument then -1 else 1
  else if typeof argument is 'number'
    options.concurrency = argument
  else
    throw Error "Invalid argument: #{position} argument `option` must be one of object, boolean or number, got #{JSON.stringify argument}" unless is_object_literal argument

normalize = () ->
  # elements, [options]
  # items, function, [options]
  # items, options, function
  elements = undefined
  options =
    concurrency: 1
    pause: false
    relax: false
  if arguments.length is 0
    elements = []
  else if arguments.length is 1
    if Array.isArray arguments[0]
      elements = arguments[0]
    else
      normalize_options options, arguments[0], 'first'
  else if arguments.length is 2
    elements = arguments[0]
    normalize_options options, arguments[1], 'second'
  else if arguments.length is 3
    elements = arguments[0]
    normalize_options options, arguments[1], 'second'
    normalize_options options, arguments[2], 'third'
    # # items, options, handler
    # if is_object_literal(arguments[1]) or ['boolean', 'number'].includes(typeof arguments[1])
    #   if is_object_literal(arguments[1])
    #     mutate options, arguments[1]
    #   else if typeof arguments[1] is 'boolean'
    #     mutate options, concurrency: if typeof arguments[1] then -1 else 1
    #   else
    #     options.concurrency = arguments[1]
    #   throw Error "Invalid argument: third argument `handler` must be a function, got #{JSON.stringify arguments[2]}" unless typeof arguments[2] is 'function'
    #   options.handler = arguments[2]
    # # items, handler, options
    # if is_object_literal(arguments[2]) or ['boolean', 'number'].includes(typeof arguments[2])
    #   throw Error "Invalid argument: third argument `handler` must be a function, got #{JSON.stringify arguments[1]}" unless typeof arguments[1] is 'function'
    #   options.handler = arguments[1]
    #   if is_object_literal(arguments[2])
    #     mutate options, arguments[2]
    #   else if typeof arguments[2] is 'boolean'
    #     mutate options, concurrency: if typeof arguments[2] then -1 else 1
    #   else
    #     options.concurrency = arguments[2]
  else
    throw Error "Invalid argument"
  elements: elements, options: options

export default (...args) ->
  { elements, options } = normalize.apply null, arguments
  stack = []
  state =
    error: false
    paused: options.pause
    running: 0
    count: -1
  internal =
    pump: ->
      return unless stack.length
      if state.error and not options.relax
        while item = stack.shift()
          item.reject.call null, state.error
      return if state.paused
      return if options.concurrency > 0 and state.running is options.concurrency
      state.running++
      item = stack.shift()
      setImmediate ->
        try
          state.count++
          result =
            if options.handler
              await options.handler.call(null, item.handler, state.count)
            else if typeof item.handler is 'function'
              await item.handler.call()
            else
              await item.handler
          state.running--
          item.resolve.call null, result
          internal.pump()
        catch error
          state.running--
          state.error = error
          item.reject.call null, error
          internal.pump()
  all = (elements, options) ->
    new Promise (resolve, reject) ->
      isArray = Array.isArray elements
      if isArray
        Promise.all(
          all element, options for element in elements
        ).then resolve, reject
      else
        stack.push
          handler: elements
          resolve: resolve
          reject: reject
          options: options
        internal.pump()
  scheduler = all elements
  scheduler.get = () ->
    if arguments.length is 0
      return merge options
    if arguments.length is 1
      return options[arguments[0]]
    else
      throw Error "Invalid argument: `get` expect one or two arguments, got #{arguments.length}"
  scheduler.pause = ->
    state.paused = true
    scheduler
  scheduler.push = (elements) ->
    all elements
  scheduler.resume = ->
    state.paused = false
    internal.pump()
    scheduler
  scheduler
